# Folly Tests - Remaining Issues

This document describes the remaining test failures in the `@folly_repo` Bazel build and provides context for future work.

## Background

### Singleton Initialization Fix

Many folly tests use singletons that require `folly::Init` to be called before the singleton registry is complete. The standard `gtest_main` doesn't call `folly::Init`, causing tests to fail with:

```
Singleton XXX requested before registrationComplete() call.
This usually means that either main() never called folly::init, or singleton was requested before main() (which is not allowed)
```

**Solution implemented:**
- Created `thirdparty/folly/folly_test_main.cpp` - A custom test main that calls `folly::Init` before running tests
- Added `folly_cc_singleton_test` macro in `thirdparty/folly/defs.bzl` for tests requiring folly initialization
- Converted 27+ tests to use the new macro

**Result:** Test failures reduced from 39 to 16.

---

## Remaining Test Failures (16 tests)

### Category A: Test Data Files (find_resource issues)

These tests use `folly::test::find_resource()` to locate test data files. This function:
1. First checks for an external hook (`folly::ext::test_find_resource`)
2. Falls back to looking for files relative to the executable path

In a Bazel sandbox, the test data files are not in the expected locations.

#### `debugging_symbolizer_ElfTest` (5 failing subtests)
- **Tests failing:** TestGetNoteGnuBuildId.SimpleElf, TestNoteSectionIteration.SimpleElf, TestNoteSegmentIteration.SimpleElf, TestNoteMultipleNoteSections.SimpleElf, TestFindNote.SimpleElf
- **Root cause:** Needs `simple_elf` binary built from `folly/debugging/symbolizer/test/SimpleElf.cpp` with linker flag `--build-id=0xdeadbeef`
- **Error:** `json parse error on line 0: expected json value` (actually a "file not found" exception being misreported)
- **Fix needed:**
  1. Build a `cc_binary` for `simple_elf` with the custom linker flag
  2. Add it as a `data` dependency
  3. Either set up the resource lookup hook or place the binary where `find_resource` expects it

#### `ssl_OpenSSLCertUtilsTest` (4 failing subtests)
- **Tests failing:** TestX509CN/0, TestX509CN/1, TestX509Store/0, TestX509Store/1
- **Root cause:** Tests look for `folly/ssl/test/ca-cert.pem` but PEM files are at `folly/io/async/test/certs/`
- **Fix needed:** Either symlink/copy certs to expected location or implement resource lookup hook

#### `io_async_ssl_BasicTransportCertificateTest`
- **Root cause:** Same as above - needs certificate files via resource lookup

#### `ThreadLocalTest` (1 failing subtest: SharedLibrary)
- **Root cause:** Test needs to load a dynamically built shared library for testing thread-local behavior across shared library boundaries
- **Fix needed:** Build the test shared library and provide it as a data dependency

### Category B: Helper Binaries Missing

These tests spawn helper executables that aren't built in our Bazel setup.

#### `cli_ProgramOptionsTest` and `cli_NestedCommandLineAppTest`
- **Root cause:** Tests try to execute `program_options_test_helper` binary
- **Error:** `failed to execute .../program_options_test_helper: No such file or directory`
- **Fix needed:** Build `cc_binary` from `folly/cli/test/ProgramOptionsTestHelper.cpp` (or similar) and add as test data

#### `FileLockTest`
- **Root cause:** Test needs `file_test_lock_helper` binary
- **Fix needed:** Build the helper binary and add as test data

### Category C: Test-Specific Issues

These failures are not related to missing resources but are genuine test issues.

#### `observer_ObserverTest`
- **Status:** TIMEOUT (300s)
- **Root cause:** Test hangs on `Observer.ObservableLockInversion` test
- **Possible fix:** Mark as `timeout = "eternal"` and `tags = ["manual"]`, or investigate the hang

#### `coro_InlineTaskTest`
- **Root cause:** Test hangs on `InlineTaskTest.DeepRecursionDoesntStackOverflow`
- **Note:** 15/18 tests pass, only the deep recursion test hangs
- **Possible fix:** Investigate stack/resource limits in Bazel sandbox

#### `futures_CleanupTest`
- **Failing test:** CleanupTest.Errors
- **Root cause:** Death test using `fork()` fails because folly detects singleton usage in child process after fork
- **Error:** `Attempting to use singleton folly::Timekeeper in child process after fork`
- **Note:** This is folly's intended safety behavior; the test may need modification for this environment

#### `compression_CompressionContextPoolTest`
- **Failing tests:** testFree, testLifo, testMultithread, testReset (CoreLocal variant)
- **Root cause:** Genuine test failures - expectations not met (e.g., `numDeleted.load() == 2` instead of expected `0`)
- **Note:** May be environment-specific or indicate real issues

#### `executors_IOThreadPoolExecutorTest`
- **Root cause:** Test failures, possibly timing-related
- **Status:** Needs investigation

#### `debugging_symbolizer_StackTraceTest`
- **Root cause:** Address comparisons fail by 1 byte (return address vs call address issue)
- **Note:** This is a known issue with stack trace comparisons

#### `io_async_AsyncSocketObserverTest`
- **Root cause:** Test failures, needs investigation

#### `ObserverContainerTest`
- **Root cause:** Test failures after folly::Init is called
- **Status:** Needs investigation

#### `SingletonThreadLocalTest`
- **Root cause:** Test failures after folly::Init is called
- **Status:** Needs investigation

---

## How to Investigate

### Check test logs
```bash
cat ~/.cache/bazel/_bazel_afei/*/execroot/_main/bazel-out/k8-fastbuild/testlogs/external/+_repo_rules2+folly_repo/<test_name>/test.log
```

### Run a specific test with verbose output
```bash
bazel test @folly_repo//:<test_name> --test_output=all
```

### Build a test binary for local debugging
```bash
bazel build @folly_repo//:<test_name>
./bazel-bin/external/+_repo_rules2+folly_repo/<test_name>
```

---

## Recommended Next Steps

1. **For Category A/B (resource issues):**
   - Implement a Bazel-compatible `test_find_resource` hook
   - Create a `genrule` or `filegroup` for test data files
   - Build helper binaries and add as `data` dependencies

2. **For Category C (test-specific):**
   - Mark problematic tests as `manual` to unblock CI
   - Investigate root causes individually

3. **General:**
   - Consider creating a `folly_test_data` filegroup for commonly needed test resources
   - The `folly::ext::test_find_resource` hook mechanism allows custom resource resolution - we could provide a Bazel-compatible implementation

---

## Current Test Statistics

| Status | Count |
|--------|-------|
| Passing | 380 |
| Failing | 16 |
| **Total** | **396** |

**Pass rate: 95.96%**
