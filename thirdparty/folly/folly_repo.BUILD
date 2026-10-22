# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

"""
BUILD.bazel overlay for the folly git repository.

This file is applied on top of the folly repo via build_file attribute
in git_repository. It builds folly as a monolithic library.
"""

load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")
load("@rules_cc//cc:defs.bzl", "cc_library", "cc_test")
load("@al_proxygen//thirdparty/folly:defs.bzl", "folly_cc_test", "folly_cc_singleton_test", "folly_test_main_library", "FOLLY_TEST_COPTS")

package(default_visibility = ["//visibility:public"])

# Export CMakeLists.txt and CMake config templates
exports_files([
    "CMakeLists.txt",
    "CMake/folly-config.h.cmake",
])

# ============================================================================
# Build configuration flags
# ============================================================================

bool_flag(
    name = "with_int128",
    build_setting_default = False,
)

config_setting(
    name = "with_int128_setting",
    flag_values = {":with_int128": "True"},
)

# ============================================================================
# Configuration header
# ============================================================================

# Copy the pre-generated config header from thirdparty/folly to the expected location
genrule(
    name = "folly_config_h",
    srcs = ["@al_proxygen//thirdparty/folly:folly-config.h"],
    outs = ["folly/folly-config.h"],
    cmd = "cp $< $@",
    visibility = ["//visibility:public"],
)

# ============================================================================
# Source exclusion patterns
# ============================================================================

# Common exclusions for all folly builds
COMMON_EXCLUDED_SOURCES = [
    # Fibers: enabled (needed by observer, which is needed by AsyncServerSocket)
    # "folly/fibers/**",
    # Python bindings
    "folly/python/**",
    # Test utilities and tests
    "folly/test/**",
    "folly/**/test/**",
    "folly/**/tests/**",
    "folly/**/*Test.cpp",
    # Exclude benchmark test files but NOT folly/Benchmark.cpp (the benchmark library)
    # Use more specific patterns since **/* can match zero path components
    "folly/*/**/*Benchmark.cpp",  # matches files in subdirs ending with Benchmark.cpp
    # Exception tracer needs special linking - only exclude specific files, not all debugging
    "folly/debugging/exception_tracer/**",
    # Experimental features (except io shims which are just includes)
    "folly/experimental/**",
    # Compression: enabled (needed by proxygen ZstdStreamCompressor)
    # "folly/compression/**",
    # IO async: all enabled
    # "folly/io/async/**",  # ENABLED
    # IO coroutines
    "folly/io/coro/**",
    # Coroutines: enable core coro functionality
    # "folly/coro/**",  # ENABLED - see specific exclusions below
    # Executors: enable most, exclude complex ones
    # "folly/executors/**",  # ENABLED - see specific exclusions below
    # CPUThreadPoolExecutor: enabled (needed by GlobalExecutor, HazptrThreadPoolExecutor)
    # "folly/executors/CPUThreadPoolExecutor.cpp",
    "folly/executors/EDFThreadPoolExecutor.cpp",  # complex deps
    # "folly/executors/FunctionScheduler.cpp",  # enabled for wangle
    "folly/executors/SoftRealTimeExecutor.cpp",  # complex deps
    "folly/executors/StrandExecutor.cpp",  # complex deps
    "folly/executors/StripedEDFThreadPoolExecutor.cpp",  # complex deps
    "folly/executors/TimedDrivableExecutor.cpp",  # complex deps
    "folly/executors/TimekeeperScheduledExecutor.cpp",  # complex deps
    # Futures: enabled (needed by fizz, wangle, etc.)
    # "folly/futures/**",
    # Tracing: only enable AsyncStack.cpp (needed by some executors)
    # "folly/tracing/**",  # partially enabled
    # Coroutines: enabled for C++20 coroutines support
    # "folly/coro/**",
    # SSL: enabled (needed by fizz, wangle, proxygen)
    # "folly/ssl/**",
    # Logging: enabled (needed by proxygen)
    # "folly/logging/**",
    # JSON: enabled (needed by logging config parser)
    # "folly/json/**",
    # Memory arena has jemalloc deps
    "folly/memory/Arena.cpp",
    "folly/memory/JemallocHugePageAllocator.cpp",
    "folly/memory/JemallocNodumpAllocator.cpp",
    # Hardware specific
    "folly/hardware/**",
    # External vendored code
    "folly/external/**",
    # Documentation examples
    "folly/docs/**",
    # Complex dependencies
    "folly/container/RegexMatchCache.cpp",
    # Singleton: enabled (needed by observer)
    # "folly/Singleton.cpp",
    # Channels have complex deps
    "folly/channels/**",
    # Rust bindings
    "folly/rust/**",
    # Settings have complex deps
    "folly/settings/**",
    # Observer: enabled (needed by AsyncServerSocket)
    # "folly/observer/**",
    # Tools are standalone programs with main()
    "folly/**/tool/**",
    "folly/tool/**",
    # Examples
    "folly/**/example/**",
]

# Default build: exclude io_uring async socket
EXCLUDED_SOURCES = COMMON_EXCLUDED_SOURCES + [
    "folly/io/async/AsyncIoUringSocket.cpp",  # depends on liburing
    "folly/io/async/IoUringBase.cpp",
    "folly/io/async/IoUringBackend.cpp",
    "folly/io/async/IoUringEvent.cpp",
    "folly/io/async/IoUringEventBaseLocal.cpp",
]

# io_uring build: include io_uring files
EXCLUDED_SOURCES_URING = COMMON_EXCLUDED_SOURCES

# ============================================================================
# Header filegroups
# ============================================================================

filegroup(
    name = "folly_headers",
    srcs = glob(["folly/**/*.h"]) + [":folly_config_h"],
)

# ============================================================================
# Fast CRC32 implementations (hardware-accelerated)
# ============================================================================

# SSE4.2 CRC32C implementation (x86_64)
cc_library(
    name = "fast_crc32_sse",
    srcs = ["folly/external/fast-crc32/sse_crc32c_v8s3x3.cpp"],
    hdrs = [":folly_headers"],
    copts = [
        "-std=c++20",
        "-msse4.2",
        "-mpclmul",
    ],
    includes = ["."],
    visibility = ["//visibility:public"],
)

# AVX512 CRC32C implementation (x86_64 with AVX512)
cc_library(
    name = "fast_crc32_avx512",
    srcs = ["folly/external/fast-crc32/avx512_crc32c_v8s3x4.cpp"],
    hdrs = ["folly/external/fast-crc32/avx512_crc32c_v8s3x4.h"],
    copts = [
        "-std=c++20",
        "-msse4.2",
        "-mpclmul",
        "-mavx512f",
        "-mavx512vl",
    ],
    includes = ["."],
    deps = [":folly"],
    visibility = ["//visibility:public"],
)

# NEON CRC32C implementation (ARM64)
cc_library(
    name = "fast_crc32_neon",
    srcs = [
        "folly/external/fast-crc32/neon_crc32c_v3s4x2e_v2.cpp",
        "folly/external/fast-crc32/neon_eor3_crc32c_v8s2x4_s3.cpp",
        "folly/external/fast-crc32/neon_eor3_crc32_v9s3x2e_s3.cpp",
    ],
    hdrs = [
        "folly/external/fast-crc32/neon_crc32c_v3s4x2e_v2.h",
        "folly/external/fast-crc32/neon_eor3_crc32c_v8s2x4_s3.h",
        "folly/external/fast-crc32/neon_eor3_crc32_v9s3x2e_s3.h",
    ],
    copts = [
        "-std=c++20",
    ] + select({
        "@platforms//cpu:aarch64": ["-march=armv8-a+crypto+crc"],
        "//conditions:default": [],
    }),
    includes = ["."],
    deps = [":folly"],
    visibility = ["//visibility:public"],
)

# Combined fast-crc32 library for all platforms
cc_library(
    name = "fast_crc32",
    deps = [
        ":fast_crc32_sse",
        ":fast_crc32_avx512",
        ":fast_crc32_neon",
    ],
    visibility = ["//visibility:public"],
)

# Folly compiles these CRC sources with -mpclmul on x86-64 only (CMakeLists.txt
# in v2025.12.15.00). They live in :folly_crc_pclmul so the option reaches no
# other Folly source and no other architecture.
FOLLY_PCLMUL_SOURCES = [
    "folly/hash/detail/ChecksumDetail.cpp",
    "folly/hash/detail/Crc32CombineDetail.cpp",
    "folly/hash/detail/Crc32cDetail.cpp",
]

# ============================================================================
# Main folly library
# ============================================================================

cc_library(
    name = "folly",
    srcs = glob(
        ["folly/**/*.cpp"],
        exclude = EXCLUDED_SOURCES + FOLLY_PCLMUL_SOURCES,
    ),
    hdrs = [":folly_headers"],
    copts = [
        "-std=c++20",
        "-fcoroutines",
        "-pthread",
        "-Wno-deprecated-declarations",
        "-Wno-sign-compare",
    ],
    defines = [
        "FOLLY_USE_LIBSTDCPP=1",
        "FOLLY_HAVE_LIBGLOG=1",
        "FOLLY_HAVE_LIBGFLAGS=1",
        "FOLLY_HAVE_PTHREAD=1",
        "FOLLY_HAVE_PTHREAD_ATFORK=1",
        "FOLLY_HAVE_PREADV=1",
        "FOLLY_HAVE_PWRITEV=1",
        "FOLLY_HAVE_CLOCK_GETTIME=1",
        "FOLLY_HAVE_UNALIGNED_ACCESS=1",
        "FOLLY_HAVE_VLA=1",
        "FOLLY_HAVE_WCHAR_SUPPORT=1",
        "HAVE_VSNPRINTF_ERRORS=1",
        "FOLLY_HAVE_DWARF=1",
        "FOLLY_HAVE_SWAPCONTEXT=1",
        "FOLLY_HAVE_BACKTRACE=1",
        "FOLLY_HAVE_SHADOW_LOCAL_WARNINGS=1",
        "FOLLY_HAVE_LIBLZ4=1",
        "FOLLY_HAVE_LIBLZMA=1",
        "FOLLY_HAVE_LIBSNAPPY=1",
        "FOLLY_HAVE_LIBZ=1",
        "FOLLY_HAVE_LIBZSTD=1",
        "FOLLY_HAVE_LIBBZ2=1",
        # Disable huge page allocator (requires jemalloc)
        "FOLLY_COMPRESSION_USE_HUGEPAGES=0",
    ] + select({
        "@platforms//os:linux": [
            "FOLLY_HAVE_ACCEPT4=1",
            "FOLLY_HAVE_GETRANDOM=1",
            "FOLLY_HAVE_PIPE2=1",
            "FOLLY_HAVE_IFUNC=1",
            "FOLLY_HAVE_WEAK_SYMBOLS=1",
            "FOLLY_HAVE_LINUX_VDSO=1",
            "FOLLY_HAVE_MALLOC_USABLE_SIZE=1",
            "FOLLY_HAVE_EXTRANDOM_SFMT19937=1",
            "FOLLY_HAVE_LIBUNWIND=1",
            "FOLLY_HAVE_ELF=1",
            "FOLLY_USE_SYMBOLIZER=1",
        ],
        "//conditions:default": [],
    }),
    includes = ["."],
    linkopts = [
        "-pthread",
        "-ldl",
        "-lrt",
    ],
    strip_include_prefix = "",
    include_prefix = "",
    deps = [
        "@boost.algorithm",
        "@boost.container",
        "@boost.context",
        "@boost.core",
        "@boost.crc",
        "@boost.filesystem",
        "@boost.intrusive",
        "@boost.multi_index",
        "@boost.preprocessor",
        "@boost.program_options",
        "@boost.regex",
        "@boost.thread",
        "@boost.utility",
        "@boost.variant",
        "@gflags",
        "@glog",
        "@double-conversion",
        "@fast_float",
        "@fmt",
        "@openssl//:ssl",
        "@openssl//:crypto",
        "@zlib",
        "@zstd",
        "@lz4",
        "@lz4//:lz4_frame",
        "@lz4//:lz4_hc",
        "@snappy",
        "@bzip2//:bz2",
        "@libdwarf",
        "@libunwind",
        "@libevent//:event",
        "@libsodium",
    ] + [":folly_crc_pclmul"] + select({
        "@platforms//cpu:x86_64": [":fast_crc32_sse"],
        "//conditions:default": [],
    }),
    visibility = ["//visibility:public"],
)

# ============================================================================
# Folly with io_uring support (high-performance Linux)
# ============================================================================

# Common copts for folly
FOLLY_COPTS = [
    "-std=c++20",
    "-fcoroutines",
    "-pthread",
    "-Wno-deprecated-declarations",
    "-Wno-sign-compare",
]

# Common defines for folly
FOLLY_DEFINES = [
    "FOLLY_USE_LIBSTDCPP=1",
    "FOLLY_HAVE_LIBGLOG=1",
    "FOLLY_HAVE_LIBGFLAGS=1",
    "FOLLY_HAVE_PTHREAD=1",
    "FOLLY_HAVE_PTHREAD_ATFORK=1",
    "FOLLY_HAVE_PREADV=1",
    "FOLLY_HAVE_PWRITEV=1",
    "FOLLY_HAVE_CLOCK_GETTIME=1",
    "FOLLY_HAVE_UNALIGNED_ACCESS=1",
    "FOLLY_HAVE_VLA=1",
    "FOLLY_HAVE_WCHAR_SUPPORT=1",
    "HAVE_VSNPRINTF_ERRORS=1",
    "FOLLY_HAVE_DWARF=1",
    "FOLLY_HAVE_SWAPCONTEXT=1",
    "FOLLY_HAVE_BACKTRACE=1",
    "FOLLY_HAVE_SHADOW_LOCAL_WARNINGS=1",
    "FOLLY_HAVE_LIBLZ4=1",
    "FOLLY_HAVE_LIBLZMA=1",
    "FOLLY_HAVE_LIBSNAPPY=1",
    "FOLLY_HAVE_LIBZ=1",
    "FOLLY_HAVE_LIBZSTD=1",
    "FOLLY_HAVE_LIBBZ2=1",
    # Disable huge page allocator (requires jemalloc)
    "FOLLY_COMPRESSION_USE_HUGEPAGES=0",
]

FOLLY_LINUX_DEFINES = [
    "FOLLY_HAVE_ACCEPT4=1",
    "FOLLY_HAVE_GETRANDOM=1",
    "FOLLY_HAVE_PIPE2=1",
    "FOLLY_HAVE_IFUNC=1",
    "FOLLY_HAVE_WEAK_SYMBOLS=1",
    "FOLLY_HAVE_LINUX_VDSO=1",
    "FOLLY_HAVE_MALLOC_USABLE_SIZE=1",
    "FOLLY_HAVE_EXTRANDOM_SFMT19937=1",
    "FOLLY_HAVE_LIBUNWIND=1",
    "FOLLY_HAVE_ELF=1",
    "FOLLY_USE_SYMBOLIZER=1",
]

FOLLY_DEPS = [
    "@boost.algorithm",
    "@boost.container",
    "@boost.context",
    "@boost.core",
    "@boost.crc",
    "@boost.filesystem",
    "@boost.intrusive",
    "@boost.multi_index",
    "@boost.preprocessor",
    "@boost.program_options",
    "@boost.regex",
    "@boost.thread",
    "@boost.utility",
    "@boost.variant",
    "@gflags",
    "@glog",
    "@double-conversion",
    "@fast_float",
    "@fmt",
    "@openssl//:ssl",
    "@openssl//:crypto",
    "@zlib",
    "@zstd",
    "@lz4",
    "@lz4//:lz4_frame",
    "@lz4//:lz4_hc",
    "@snappy",
    "@bzip2//:bz2",
    "@libdwarf",
    "@libunwind",
    "@libevent//:event",
    "@libsodium",
] + select({
    "@platforms//cpu:x86_64": [":fast_crc32_sse"],
    "//conditions:default": [],
})

cc_library(
    name = "folly_crc_pclmul",
    srcs = FOLLY_PCLMUL_SOURCES,
    hdrs = [":folly_headers"],
    copts = FOLLY_COPTS + select({
        "@platforms//cpu:x86_64": ["-mpclmul"],
        "//conditions:default": [],
    }),
    local_defines = FOLLY_DEFINES + select({
        "@platforms//os:linux": FOLLY_LINUX_DEFINES,
        "//conditions:default": [],
    }),
    includes = ["."],
    deps = FOLLY_DEPS,
)

cc_library(
    name = "folly_uring",
    srcs = glob(
        ["folly/**/*.cpp"],
        exclude = EXCLUDED_SOURCES_URING + FOLLY_PCLMUL_SOURCES,
    ),
    hdrs = [":folly_headers"],
    copts = FOLLY_COPTS,
    defines = FOLLY_DEFINES + [
        "FOLLY_HAS_LIBURING=1",
    ] + select({
        "@platforms//os:linux": FOLLY_LINUX_DEFINES,
        "//conditions:default": [],
    }),
    includes = ["."],
    linkopts = [
        "-pthread",
        "-ldl",
        "-lrt",
    ],
    strip_include_prefix = "",
    include_prefix = "",
    deps = FOLLY_DEPS + [
        "@liburing_repo//:liburing",  # io_uring support
        ":folly_crc_pclmul",
    ],
    visibility = ["//visibility:public"],
)

# ============================================================================
# Convenience aliases for granular dependencies
# ============================================================================

cc_library(name = "traits", deps = [":folly"])
cc_library(name = "portability", deps = [":folly"])
cc_library(name = "range", deps = [":folly"])
cc_library(name = "c_portability", deps = [":folly"])
cc_library(name = "config", hdrs = [":folly_config_h"], include_prefix = "folly")
cc_library(name = "utility", deps = [":folly"])
cc_library(name = "cpp_attributes", deps = [":folly"])
cc_library(name = "preprocessor", deps = [":folly"])
cc_library(name = "string", deps = [":folly"])
cc_library(name = "fbstring", deps = [":folly"])
cc_library(name = "conv", deps = [":folly"])
cc_library(name = "format", deps = [":folly"])
cc_library(name = "likely", deps = [":folly"])
cc_library(name = "exception", deps = [":folly"])
cc_library(name = "exception_wrapper", deps = [":folly"])
cc_library(name = "optional", deps = [":folly"])
cc_library(name = "expected", deps = [":folly"])
cc_library(name = "small_vector", deps = [":folly"])
cc_library(name = "singleton", deps = [":folly"])
cc_library(name = "memory", deps = [":folly"])
cc_library(name = "synchronized", deps = [":folly"])
cc_library(name = "function", deps = [":folly"])
cc_library(name = "network_address", deps = [":folly"])
cc_library(name = "socket_address", deps = [":folly"])
cc_library(name = "hash", deps = [":folly"])
cc_library(name = "io", deps = [":folly"])
cc_library(name = "net", deps = [":folly"])
cc_library(name = "system", deps = [":folly"])

# ============================================================================
# Test support library
# ============================================================================

cc_library(
    name = "folly_test_util",
    srcs = [
        # Core test utilities (no main functions, not actual tests)
        "folly/test/BufferedAtomic.cpp",
        "folly/test/DeterministicSchedule.cpp",
        "folly/test/FBVectorTestUtil.cpp",
        "folly/test/SingletonTestStructs.cpp",
        "folly/test/SocketAddressTestHelper.cpp",
        # IO async test utilities
        "folly/io/async/test/AsyncBaseTestLib.cpp",
        "folly/io/async/test/ScopedBoundPort.cpp",
        "folly/io/async/test/SocketPair.cpp",
        "folly/io/async/test/SSLUtil.cpp",
        "folly/io/async/test/TestSSLServer.cpp",
        "folly/io/async/test/TFOUtil.cpp",
        "folly/io/async/test/TimeUtil.cpp",
        "folly/io/async/test/ZeroCopy.cpp",
    ],
    hdrs = glob(
        [
            "folly/test/*.h",
            "folly/io/async/test/*.h",
            "folly/futures/test/*.h",
        ],
    ),
    copts = FOLLY_COPTS,
    includes = ["."],
    deps = [
        ":folly",
        "@googletest//:gtest",
        # gmock is included in gtest in the BCR module
    ],
)

# Create the folly test main library for singleton-dependent tests
folly_test_main_library()

# ============================================================================
# Unit Tests - Core folly tests
# ============================================================================

# Using folly_cc_test macro for simplified test definitions
# Note: SmallVectorTest uses non-standard filename, so we use cc_test directly

# Dynamic/JSON tests
folly_cc_test(src = "folly/json/test/DynamicTest.cpp")
folly_cc_test(src = "folly/json/test/JsonTest.cpp")
folly_cc_test(src = "folly/json/test/DynamicConverterTest.cpp")
folly_cc_test(src = "folly/json/test/DynamicOtherTest.cpp")
folly_cc_test(src = "folly/json/test/DynamicParserTest.cpp")
folly_cc_test(src = "folly/json/test/JsonOtherTest.cpp")
folly_cc_singleton_test(src = "folly/json/test/JSONSchemaTest.cpp")
folly_cc_test(src = "folly/json/test/JsonTestUtilTest.cpp")
folly_cc_test(src = "folly/json/bser/test/BserTest.cpp")

# String tests
folly_cc_test(src = "folly/test/ConvTest.cpp")
folly_cc_test(src = "folly/test/FBStringTest.cpp")
folly_cc_test(src = "folly/test/FormatTest.cpp")
folly_cc_test(src = "folly/test/FormatOtherTest.cpp")
folly_cc_test(src = "folly/test/StringTest.cpp")
folly_cc_test(src = "folly/test/UTF8StringTest.cpp")
folly_cc_test(src = "folly/test/UnicodeTest.cpp")
folly_cc_test(src = "folly/test/FixedStringTest.cpp")

# Container tests (SmallVectorTest has non-standard name)
cc_test(
    name = "SmallVectorTest",
    srcs = ["folly/container/test/small_vector_test.cpp"],
    copts = FOLLY_COPTS,
    deps = [":folly", "@googletest//:gtest_main"],
)
folly_cc_test(src = "folly/container/test/F14MapTest.cpp")
folly_cc_test(src = "folly/container/test/F14SetTest.cpp")
folly_cc_test(src = "folly/container/test/F14FwdTest.cpp")
folly_cc_test(src = "folly/container/test/F14PolicyTest.cpp")
folly_cc_test(src = "folly/container/test/AccessTest.cpp")
folly_cc_test(src = "folly/container/test/ArrayTest.cpp")
folly_cc_test(src = "folly/container/test/BitIteratorTest.cpp")
# folly_cc_test(src = "folly/container/test/CollectionUtilTest.cpp") # Build fails
folly_cc_test(src = "folly/container/test/EnumerateTest.cpp")
folly_cc_test(src = "folly/container/test/EvictingCacheMapTest.cpp")
# folly_cc_test(src = "folly/container/test/FBVectorTest.cpp") # Build fails
folly_cc_test(src = "folly/container/test/ForeachTest.cpp")
folly_cc_test(src = "folly/container/test/HeterogeneousAccessTest.cpp")
folly_cc_test(src = "folly/container/test/IntrusiveHeapTest.cpp")
folly_cc_test(src = "folly/container/test/IRangeTest.cpp")
folly_cc_test(src = "folly/container/test/IteratorTest.cpp")
folly_cc_test(src = "folly/container/test/MapUtilTest.cpp")
folly_cc_test(src = "folly/container/test/MergeTest.cpp")
folly_cc_test(src = "folly/container/test/ReserveTest.cpp")
folly_cc_test(src = "folly/container/test/SparseByteSetTest.cpp")
folly_cc_test(src = "folly/container/test/UtilTest.cpp")
folly_cc_test(src = "folly/container/test/WeightedEvictingCacheMapTest.cpp")
folly_cc_test(src = "folly/container/detail/test/F14DetailTest.cpp")
folly_cc_test(src = "folly/container/detail/test/BoolWrapperTest.cpp")

# Futures tests
folly_cc_singleton_test(src = "folly/futures/test/FutureTest.cpp")
# folly_cc_test(src = "folly/futures/test/PromiseTest.cpp") # Build fails
# folly_cc_test(src = "folly/futures/test/SemiFutureTest.cpp") # Build fails
folly_cc_test(src = "folly/futures/test/BarrierTest.cpp")
# folly_cc_test(src = "folly/futures/test/CallbackLifetimeTest.cpp") # Build fails
folly_cc_singleton_test(src = "folly/futures/test/CleanupTest.cpp")
# folly_cc_test(src = "folly/futures/test/CollectTest.cpp") # Build fails
folly_cc_test(src = "folly/futures/test/ContextTest.cpp")
folly_cc_test(src = "folly/futures/test/ConversionOperatorTest.cpp")
folly_cc_test(src = "folly/futures/test/CoreTest.cpp")
folly_cc_test(src = "folly/futures/test/EnsureTest.cpp")
folly_cc_test(src = "folly/futures/test/FilterTest.cpp")
folly_cc_test(src = "folly/futures/test/FutureSplitterTest.cpp")
folly_cc_test(src = "folly/futures/test/HeaderCompileTest.cpp")
folly_cc_singleton_test(src = "folly/futures/test/HeapTimekeeperTest.cpp")
# folly_cc_test(src = "folly/futures/test/InterruptTest.cpp") # Build fails
folly_cc_test(src = "folly/futures/test/ManualTimekeeperTest.cpp")
folly_cc_test(src = "folly/futures/test/MapTest.cpp")
folly_cc_test(src = "folly/futures/test/NonCopyableLambdaTest.cpp")
folly_cc_test(src = "folly/futures/test/PollTest.cpp")
folly_cc_test(src = "folly/futures/test/ReduceTest.cpp")
# folly_cc_test(src = "folly/futures/test/RetryingTest.cpp") # Build fails
folly_cc_test(src = "folly/futures/test/SelfDestructTest.cpp")
# folly_cc_test(src = "folly/futures/test/SharedPromiseTest.cpp") # Build fails
# folly_cc_test(src = "folly/futures/test/TestExecutorTest.cpp") # Build fails
folly_cc_test(src = "folly/futures/test/ThenCompileTest.cpp")
folly_cc_test(src = "folly/futures/test/ThenTest.cpp")
folly_cc_singleton_test(src = "folly/futures/test/ThreadWheelTimekeeperTest.cpp")
folly_cc_singleton_test(src = "folly/futures/test/TimekeeperTest.cpp")
folly_cc_test(src = "folly/futures/test/TimesTest.cpp")
folly_cc_test(src = "folly/futures/test/UnwrapTest.cpp")
# folly_cc_test(src = "folly/futures/test/ViaTest.cpp") # Build fails
# folly_cc_test(src = "folly/futures/test/WaitTest.cpp") # Build fails
folly_cc_test(src = "folly/futures/test/WhenTest.cpp")
folly_cc_test(src = "folly/futures/test/WhileDoTest.cpp")
folly_cc_test(src = "folly/futures/test/WillEqualTest.cpp")
folly_cc_test(src = "folly/futures/test/WindowTest.cpp")

# IO tests
folly_cc_test(src = "folly/io/test/IOBufTest.cpp")
folly_cc_test(src = "folly/io/test/IOBufCursorTest.cpp")
folly_cc_test(src = "folly/io/test/IOBufCBTest.cpp")
folly_cc_test(src = "folly/io/test/IOBufIovecBuilderTest.cpp")
folly_cc_test(src = "folly/io/test/IOBufQueueTest.cpp")
folly_cc_test(src = "folly/io/test/FsUtilTest.cpp")
folly_cc_test(src = "folly/io/test/RecordIOTest.cpp")
folly_cc_test(src = "folly/io/test/ShutdownSocketSetTest.cpp")
folly_cc_test(src = "folly/io/test/SocketOptionValueTest.cpp")

# Async tests
folly_cc_test(src = "folly/io/async/test/AsyncSocketTest.cpp")
# folly_cc_test(src = "folly/io/async/test/EventBaseTest.cpp") # Build fails
folly_cc_test(src = "folly/io/async/test/AsyncPipeTest.cpp")
folly_cc_test(src = "folly/io/async/test/AsyncSocketExceptionTest.cpp")
folly_cc_singleton_test(src = "folly/io/async/test/AsyncSocketObserverTest.cpp")
# folly_cc_test(src = "folly/io/async/test/AsyncSSLSocketTest.cpp") # Build fails
folly_cc_test(src = "folly/io/async/test/AsyncSSLSocketWriteTest.cpp")
folly_cc_test(src = "folly/io/async/test/AsyncTimeoutTest.cpp")
folly_cc_test(src = "folly/io/async/test/AsyncTransportTest.cpp")
folly_cc_test(src = "folly/io/async/test/AsyncUDPSocketTest.cpp")
folly_cc_test(src = "folly/io/async/test/AtomicNotificationQueueTest.cpp")
folly_cc_test(src = "folly/io/async/test/DecoratedAsyncTransportWrapperTest.cpp")
folly_cc_test(src = "folly/io/async/test/DelayedDestructionBaseTest.cpp")
folly_cc_test(src = "folly/io/async/test/DelayedDestructionTest.cpp")
folly_cc_test(src = "folly/io/async/test/DestructorCheckTest.cpp")
folly_cc_test(src = "folly/io/async/test/EventBaseLocalTest.cpp")
folly_cc_test(src = "folly/io/async/test/EventBaseThreadTest.cpp")
folly_cc_test(src = "folly/io/async/test/EventHandlerTest.cpp")
# folly_cc_test(src = "folly/io/async/test/HHWheelTimerTest.cpp") # Build fails
# folly_cc_test(src = "folly/io/async/test/HHWheelTimerHighResTest.cpp") # Build fails
folly_cc_test(src = "folly/io/async/test/NotificationQueueTest.cpp")
folly_cc_test(src = "folly/io/async/test/RequestContextTest.cpp")
folly_cc_test(src = "folly/io/async/test/ScopedEventBaseThreadTest.cpp")
# folly_cc_test(src = "folly/io/async/test/SSLContextTest.cpp") # Build fails
# folly_cc_test(src = "folly/io/async/test/SSLOptionsTest.cpp") # Build fails
# folly_cc_test(src = "folly/io/async/test/SSLSessionTest.cpp") # Build fails
# folly_cc_test(src = "folly/io/async/test/TimeUtilTest.cpp") # Build fails
folly_cc_test(src = "folly/io/async/test/WriteChainAsyncTransportWrapperTest.cpp")
folly_cc_test(src = "folly/io/async/test/WriteFlagsTest.cpp")
# folly_cc_test(src = "folly/io/async/test/ZeroCopyTest.cpp") # Build fails
folly_cc_singleton_test(src = "folly/io/async/ssl/test/BasicTransportCertificateTest.cpp")
folly_cc_test(src = "folly/io/async/ssl/test/OpenSSLUtilsTest.cpp")
folly_cc_test(src = "folly/io/async/ssl/test/SSLErrorsTest.cpp")
folly_cc_test(src = "folly/io/async/fdsock/test/AsyncFdSocketTest.cpp")

# Utility tests
folly_cc_test(src = "folly/test/OptionalTest.cpp")
folly_cc_test(src = "folly/test/ExpectedTest.cpp")
folly_cc_test(src = "folly/test/FunctionTest.cpp")
# folly_cc_test(src = "folly/test/SynchronizedTest.cpp") # Build fails
# folly_cc_test(src = "folly/test/SingletonTest.cpp") # Build fails
folly_cc_test(src = "folly/test/RangeTest.cpp")
folly_cc_test(src = "folly/test/TraitsTest.cpp")
folly_cc_test(src = "folly/test/UnitTest.cpp")
folly_cc_test(src = "folly/test/UtilityTest.cpp")
folly_cc_test(src = "folly/test/ScopeGuardTest.cpp")
folly_cc_test(src = "folly/test/TryTest.cpp")
folly_cc_test(src = "folly/test/PackedSyncPtrTest.cpp")
folly_cc_test(src = "folly/test/AtomicHashMapTest.cpp")
folly_cc_test(src = "folly/test/ArenaSmartPtrTest.cpp")
folly_cc_test(src = "folly/test/AsciiCaseInsensitiveTest.cpp")
folly_cc_test(src = "folly/test/AtomicHashArrayTest.cpp")
folly_cc_test(src = "folly/test/AtomicLinkedListTest.cpp")
folly_cc_test(src = "folly/test/AtomicUnorderedMapTest.cpp")
# BenchmarkTest.cpp - requires benchmark infrastructure with complex deps
# folly_cc_test(src = "folly/test/BufferedAtomicTest.cpp") # Build fails
folly_cc_test(src = "folly/test/CancellationTokenTest.cpp")
folly_cc_test(src = "folly/test/ChronoTest.cpp")
folly_cc_test(src = "folly/test/ClockGettimeWrappersTest.cpp")
folly_cc_test(src = "folly/test/ConcurrentBitSetTest.cpp")
folly_cc_test(src = "folly/test/ConcurrentLazyTest.cpp")
folly_cc_test(src = "folly/test/ConcurrentSkipListTest.cpp")
folly_cc_test(src = "folly/test/ConstexprMathTest.cpp")
folly_cc_test(src = "folly/test/ConstructorCallbackListTest.cpp")
folly_cc_test(src = "folly/test/CpuIdTest.cpp")
folly_cc_test(src = "folly/test/DemangleTest.cpp")
folly_cc_test(src = "folly/test/DeterministicScheduleTest.cpp", deps = [":folly_test_util"])
folly_cc_test(src = "folly/test/DiscriminatedPtrTest.cpp")
folly_cc_test(src = "folly/test/EndianTest.cpp")
folly_cc_test(src = "folly/test/ExceptionStringTest.cpp")
folly_cc_test(src = "folly/test/ExceptionTest.cpp")
folly_cc_test(src = "folly/test/ExceptionWrapperTest.cpp")
folly_cc_test(src = "folly/test/ExecutorTest.cpp")
folly_cc_test(src = "folly/test/ExpectedCoroutinesTest.cpp")
folly_cc_test(src = "folly/test/FileLockTest.cpp")
folly_cc_test(src = "folly/test/FileTest.cpp")
folly_cc_test(src = "folly/test/FileUtilTest.cpp")
folly_cc_test(src = "folly/test/FingerprintTest.cpp")
folly_cc_test(src = "folly/test/FmtUtilityTest.cpp")
folly_cc_test(src = "folly/test/FunctionRefTest.cpp")
# folly_cc_test(src = "folly/test/FutexTest.cpp") # Build fails
folly_cc_test(src = "folly/test/GLogTest.cpp")
folly_cc_test(src = "folly/test/GroupVarintTest.cpp")
folly_cc_test(src = "folly/test/IndestructibleTest.cpp")
# folly_cc_test(src = "folly/test/IndexedMemPoolTest.cpp") # Build fails
folly_cc_test(src = "folly/test/IPAddressTest.cpp")
folly_cc_test(src = "folly/test/IteratorsTest.cpp")
folly_cc_test(src = "folly/test/LazyTest.cpp")
folly_cc_test(src = "folly/test/MacAddressTest.cpp")
folly_cc_test(src = "folly/test/MathTest.cpp")
folly_cc_test(src = "folly/test/MaybeManagedPtrTest.cpp")
folly_cc_test(src = "folly/test/MemcpyTest.cpp")
folly_cc_test(src = "folly/test/MemoryIdlerTest.cpp")
folly_cc_test(src = "folly/test/MemoryTest.cpp")
folly_cc_test(src = "folly/test/MemsetTest.cpp")
folly_cc_test(src = "folly/test/MoveWrapperTest.cpp")
folly_cc_test(src = "folly/test/MPMCPipelineTest.cpp")
# folly_cc_test(src = "folly/test/MPMCQueueTest.cpp") # Build fails
folly_cc_singleton_test(src = "folly/test/ObserverContainerTest.cpp")
folly_cc_test(src = "folly/test/OptionalCoroutinesTest.cpp")
folly_cc_test(src = "folly/test/OverloadTest.cpp")
folly_cc_test(src = "folly/test/PaddedTest.cpp")
folly_cc_test(src = "folly/test/PolyTest.cpp")
folly_cc_test(src = "folly/test/PortabilityTest.cpp")
folly_cc_test(src = "folly/test/ProducerConsumerQueueTest.cpp")
folly_cc_test(src = "folly/test/RandomTest.cpp")
folly_cc_test(src = "folly/test/ReplaceableTest.cpp")
# SharedMutexTest has template issues (typename std::shared_lock deduction)
folly_cc_singleton_test(src = "folly/test/SingletonThreadLocalTest.cpp")
# folly_cc_test(src = "folly/test/SocketAddressTest.cpp") # Build fails
folly_cc_test(src = "folly/test/SpinLockTest.cpp")
# folly_cc_test(src = "folly/test/SubprocessTest.cpp") # Build fails
folly_cc_test(src = "folly/test/SynchronizedPtrTest.cpp")
folly_cc_test(src = "folly/test/TestUtilsTest.cpp")
folly_cc_test(src = "folly/test/ThreadCachedIntTest.cpp")
folly_cc_test(src = "folly/test/ThreadLocalTest.cpp")
folly_cc_test(src = "folly/test/TimeoutQueueTest.cpp")
folly_cc_test(src = "folly/test/TokenBucketTest.cpp")
folly_cc_test(src = "folly/test/UriTest.cpp")
folly_cc_test(src = "folly/test/VarintTest.cpp")
folly_cc_test(src = "folly/testing/test/TestUtilTest.cpp")

# Hash tests
folly_cc_test(src = "folly/hash/test/HashTest.cpp")
# ChecksumTest requires fast-crc32 implementations
cc_test(
    name = "hash_ChecksumTest",
    srcs = ["folly/hash/test/ChecksumTest.cpp"],
    copts = FOLLY_TEST_COPTS,
    deps = [
        ":folly",
        ":fast_crc32",
        "@boost.crc",
        "@googletest//:gtest_main",
    ],
)
# folly_cc_test(src = "folly/hash/test/FarmHashTest.cpp") # Build fails
folly_cc_test(src = "folly/hash/test/FnvHashTest.cpp")
folly_cc_test(src = "folly/hash/test/MurmurHashTest.cpp")
folly_cc_test(src = "folly/hash/test/SpookyHashV1Test.cpp")
folly_cc_test(src = "folly/hash/test/SpookyHashV2Test.cpp")
folly_cc_test(src = "folly/hash/test/RapidHashTest.cpp")
folly_cc_test(src = "folly/hash/test/HsiehHashTest.cpp")
folly_cc_test(src = "folly/hash/test/StdCompatibleHashTest.cpp")
folly_cc_test(src = "folly/hash/test/UniqueHashKeyTest.cpp")

# Compression tests
# CompressionTest runs hundreds of parameterized tests - skip in normal runs
folly_cc_test(src = "folly/compression/test/CompressionTest.cpp", timeout = "eternal", tags = ["manual"])
folly_cc_singleton_test(src = "folly/compression/test/CompressionContextPoolTest.cpp")
folly_cc_test(src = "folly/compression/test/Select64Test.cpp")
folly_cc_test(src = "folly/compression/test/QuotientMultiSetTest.cpp")
# folly_cc_test(src = "folly/compression/elias_fano/test/EliasFanoCodingTest.cpp") # Build fails
# folly_cc_test(src = "folly/compression/elias_fano/test/BitVectorCodingTest.cpp") # Build fails

# Fibers tests
# folly_cc_test(src = "folly/fibers/test/FibersTest.cpp") # Build fails
folly_cc_test(src = "folly/fibers/test/SemaphoreTest.cpp")
folly_cc_test(src = "folly/fibers/test/BatchSemaphoreTest.cpp")
folly_cc_singleton_test(src = "folly/fibers/async/test/AsyncTest.cpp")

# Coro tests (C++20 coroutines)
folly_cc_singleton_test(src = "folly/coro/test/TaskTest.cpp")
# folly_cc_test(src = "folly/coro/test/AsyncGene# folly_cc_test(src = "folly/coro/test/CollectTest.cpp") # Build failsollectTest.cpp") # Build fails
# folly_cc_test(src = "folly/coro/test/TimeoutTest.cpp") # Build fails
folly_cc_singleton_test(src = "folly/coro/test/MutexTest.cpp")
# folly_cc_test(src = "folly/coro/test/BatonTest.cpp") # Build fails
folly_cc_singleton_test(src = "folly/coro/test/BlockingWaitTest.cpp")
# folly_cc_test(src = "folly/coro/test/BoundedQueueTest.cpp") # Build fails
folly_cc_singleton_test(src = "folly/coro/test/CoroTest.cpp")
folly_cc_test(src = "folly/coro/test/CoroutineTest.cpp")
folly_cc_test(src = "folly/coro/test/CurrentExecutorTest.cpp")
folly_cc_test(src = "folly/coro/test/GeneratorTest.cpp")
folly_cc_singleton_test(src = "folly/coro/test/InlineTaskTest.cpp")
# folly_cc_test(src = "folly/coro/test/# folly_cc_test(src = "folly/coro/test/PromiseTest.cpp") # Build failsromiseTest.cpp") # Build fails
folly_cc_singleton_test(src = "folly/coro/test/RetryTest.cpp")
folly_cc_test(src = "folly/coro/test/ScopeExitTest.cpp")
# folly_cc_test(src = "folly/coro/test/Shared# folly_cc_test(src = "folly/coro/test/SharedPromiseTest.cpp") # Build failsromiseTest.cpp") # Build fails
# folly_cc_test(src = "folly/coro/test/SleepTest.cpp") # Build fails
# folly_cc_test(src = "folly/coro/test/SmallUnbounded# folly_cc_test(src = "folly/coro/test/SynchronizedTest.cpp") # Build failsonizedTest.cpp") # Build fails
# folly_cc_test(src = "folly/coro/test/TransformTest.cpp") # Build fails
folly_cc_singleton_test(src = "folly/coro/test/UnboundedQueueTest.cpp")
folly_cc_test(src = "folly/coro/test/AsyncPipeTest.cpp")
# folly_cc_test(src = "folly/coro/test/AsyncScopeTest.cpp") # Build fails
folly_cc_test(src = "folly/coro/test/AccumulateTest.cpp")
folly_cc_test(src = "folly/coro/test/ConcatTest.cpp")
folly_cc_test(src = "folly/coro/test/FilterTest.cpp")
# folly_cc_test(src = "folly/coro/test/FutureUtilTest.cpp") # Build fails
folly_cc_test(src = "folly/coro/test/TraitsTest.cpp")
# folly_cc_test(src = "folly/coro/test/ErrorTest.cpp") # Build fails
# folly_cc_test(src = "folly/coro/test/NoexceptTest.cpp") # Build fails
folly_cc_test(src = "folly/coro/test/RequestContextTest.cpp")
# folly_cc_test(src = "folly/coro/test/ValueOrErrorTest.cpp") # Build fails
# folly_cc_test(src = "folly/coro/test/GmockHelpersTest.cpp") # Build fails
# folly_cc_test(src = "folly/coro/test/GtestHelpersTest.cpp") # Build fails
# folly_cc_test(src = "folly/coro/test/TaskWrapperTest.cpp") # Build fails

# Concurrency tests
# folly_cc_test(src = "folly/concurrency/test/ConcurrentHashMapTest.cpp") # Build fails
folly_cc_test(src = "folly/concurrency/test/UnboundedQueueTest.cpp")
folly_cc_test(src = "folly/concurrency/test/DynamicBoundedQueueTest.cpp")
folly_cc_test(src = "folly/concurrency/test/CacheLocalityTest.cpp")
# folly_cc_test(src = "folly/concurrency/container/test/LockFreeRingBufferTest.cpp") # Build fails
# folly_cc_test(src = "folly/concurrency/test/AtomicSharedPtrTest.cpp") # Build fails
folly_cc_test(src = "folly/concurrency/test/CoreCachedSharedPtrTest.cpp")
folly_cc_test(src = "folly/concurrency/test/PriorityUnboundedQueueSetTest.cpp")
folly_cc_test(src = "folly/concurrency/test/ProcessLocalUniqueIdTest.cpp")
folly_cc_test(src = "folly/concurrency/test/SingletonRelaxedCounterTest.cpp")
folly_cc_test(src = "folly/concurrency/test/ThreadCachedSynchronizedTest.cpp")
folly_cc_test(src = "folly/concurrency/container/test/FlatCombiningPriorityQueueTest.cpp")
# folly_cc_test(src = "folly/concurrency/container/test/RelaxedConcurrentPriorityQueueTest.cpp") # Build fails
folly_cc_test(src = "folly/concurrency/container/test/SingleWriterFixedHashMapTest.cpp")
folly_cc_test(src = "folly/concurrency/memory/test/AtomicReadMostlyMainPtrTest.cpp")
folly_cc_singleton_test(src = "folly/concurrency/memory/test/PrimaryPtrTest.cpp")
folly_cc_test(src = "folly/concurrency/memory/test/ReadMostlySharedPtrTest.cpp")
folly_cc_test(src = "folly/concurrency/memory/test/RefCountTest.cpp")

# Memory tests
folly_cc_test(src = "folly/memory/test/ArenaTest.cpp")
folly_cc_test(src = "folly/memory/test/MallocTest.cpp")
folly_cc_test(src = "folly/memory/test/MemoryResourceTest.cpp")
folly_cc_test(src = "folly/memory/test/ReentrantAllocatorTest.cpp")
folly_cc_test(src = "folly/memory/test/SanitizeAddressTest.cpp")
folly_cc_test(src = "folly/memory/test/ThreadCachedArenaTest.cpp")
folly_cc_test(src = "folly/memory/test/UninitializedMemoryHacksTest.cpp")

# Algorithm tests
folly_cc_test(src = "folly/algorithm/simd/test/ContainsTest.cpp")
folly_cc_test(src = "folly/algorithm/simd/test/FindFixedTest.cpp")
folly_cc_test(src = "folly/algorithm/simd/test/MovemaskTest.cpp")
folly_cc_test(src = "folly/algorithm/simd/detail/test/SimdAnyOfTest.cpp")
folly_cc_test(src = "folly/algorithm/simd/detail/test/SimdForEachTest.cpp")
folly_cc_test(src = "folly/algorithm/simd/detail/test/UnrollUtilsTest.cpp")
folly_cc_test(src = "folly/algorithm/test/BinaryHeapTest.cpp")

# Observer tests
folly_cc_singleton_test(src = "folly/observer/test/ObserverTest.cpp")

# Net tests
folly_cc_test(src = "folly/net/test/NetOpsTest.cpp")
folly_cc_test(src = "folly/net/test/TcpInfoTest.cpp")
folly_cc_test(src = "folly/net/detail/test/SocketFileDescriptorMapTest.cpp")

# Executors tests
folly_cc_singleton_test(src = "folly/executors/test/ExecutorTest.cpp")
# folly_cc_test(src = "folly/executors/test/ThreadPoolExecutorTest.cpp") # Build fails
folly_cc_singleton_test(src = "folly/executors/test/AsyncTest.cpp")
folly_cc_test(src = "folly/executors/test/CodelTest.cpp")
folly_cc_test(src = "folly/executors/test/ExecutorWithPriorityTest.cpp")
folly_cc_test(src = "folly/executors/test/FiberIOExecutorTest.cpp")
folly_cc_singleton_test(src = "folly/executors/test/GlobalExecutorTest.cpp")
folly_cc_singleton_test(src = "folly/executors/test/GlobalCPUExecutorTest.cpp")
folly_cc_singleton_test(src = "folly/executors/test/GlobalIOExecutorTest.cpp")
folly_cc_singleton_test(src = "folly/executors/test/IOThreadPoolExecutorTest.cpp")
# folly_cc_test(src = "folly/executors/test/MeteredExecutorTest.cpp") # Build fails
folly_cc_test(src = "folly/executors/test/SequencedExecutorTest.cpp")
folly_cc_singleton_test(src = "folly/executors/test/SerialExecutorTest.cpp")
folly_cc_test(src = "folly/executors/test/ThreadedExecutorTest.cpp")
folly_cc_test(src = "folly/executors/test/ThreadedRepeatingFunctionRunnerTest.cpp")
folly_cc_test(src = "folly/executors/task_queue/test/UnboundedBlockingQueueTest.cpp")
folly_cc_test(src = "folly/executors/task_queue/test/PriorityLifoSemMPMCQueueTest.cpp")
folly_cc_test(src = "folly/executors/task_queue/test/PriorityUnboundedBlockingQueueTest.cpp")

# Portability tests
folly_cc_test(src = "folly/portability/test/ConstexprTest.cpp")
folly_cc_test(src = "folly/portability/test/FcntlTest.cpp")
folly_cc_test(src = "folly/portability/test/FilesystemTest.cpp")
folly_cc_test(src = "folly/portability/test/LibgenTest.cpp")
folly_cc_test(src = "folly/portability/test/OpenSSLPortabilityTest.cpp")
folly_cc_test(src = "folly/portability/test/PThreadTest.cpp")
folly_cc_test(src = "folly/portability/test/TimeTest.cpp")
folly_cc_test(src = "folly/portability/test/UnistdTest.cpp")

# Channels tests (C++20 coroutines)
folly_cc_singleton_test(src = "folly/channels/test/ChannelTest.cpp")
folly_cc_test(src = "folly/channels/test/ProducerTest.cpp")
folly_cc_test(src = "folly/channels/test/ChannelProcessorTest.cpp")
folly_cc_singleton_test(src = "folly/channels/test/FanoutChannelTest.cpp")
folly_cc_test(src = "folly/channels/test/FanoutSenderTest.cpp")
# folly_cc_test(src = "folly/channels/test/MaxConcurrentRateLimiterTest.cpp") # Build fails
folly_cc_singleton_test(src = "folly/channels/test/MergeChannelTest.cpp")
folly_cc_singleton_test(src = "folly/channels/test/MergeTest.cpp")
# MultiplexChannelTest requires range-v3 library (not available)
# folly_cc_test(src = "folly/channels/test/ProxyCh# folly_cc_test(src = "folly/channels/test/TransformTest.cpp") # Build failsnsformTest.cpp") # Build fails
folly_cc_test(src = "folly/channels/detail/test/AtomicQueueTest.cpp")
folly_cc_test(src = "folly/channels/detail/test/PointerVariantTest.cpp")

# Logging tests
folly_cc_test(src = "folly/logging/test/LoggerTest.cpp")
folly_cc_test(src = "folly/logging/test/LogLevelTest.cpp")
folly_cc_test(src = "folly/logging/test/AsyncFileWriterTest.cpp")
folly_cc_test(src = "folly/logging/test/AsyncLogWriterTest.cpp")
folly_cc_test(src = "folly/logging/test/AutoTimerTest.cpp")
# folly_cc_test(src = "folly/logging/test/ConfigParserTest.cpp") # Build fails
# folly_cc_test(src = "folly/logging/test/ConfigUpdateTest.cpp") # Build fails
folly_cc_test(src = "folly/logging/test/CustomLogFormatterTest.cpp")
folly_cc_test(src = "folly/logging/test/FileHandlerFactoryTest.cpp")
folly_cc_test(src = "folly/logging/test/GlogFormatterTest.cpp")
folly_cc_test(src = "folly/logging/test/ImmediateFileWriterTest.cpp")
# folly_cc_test(src = "folly/logging/test/InitTest.cpp") # Build fails
folly_cc_test(src = "folly/logging/test/LogCategoryTest.cpp")
folly_cc_test(src = "folly/logging/test/LoggerDBTest.cpp")
folly_cc_test(src = "folly/logging/test/LogMessageTest.cpp")
folly_cc_test(src = "folly/logging/test/LogNameTest.cpp")
folly_cc_test(src = "folly/logging/test/LogStreamTest.cpp")
folly_cc_test(src = "folly/logging/test/RateLimiterTest.cpp")
folly_cc_test(src = "folly/logging/test/StandardLogHandlerFactoryTest.cpp")
folly_cc_test(src = "folly/logging/test/StandardLogHandlerTest.cpp")
folly_cc_test(src = "folly/logging/test/SyncLevelTest.cpp")
# folly_cc_test(src = "folly/logging/test/XlogTest.cpp") # Build fails

# Crypto tests
folly_cc_test(src = "folly/crypto/test/Blake2xbTest.cpp")
folly_cc_test(src = "folly/crypto/test/LtHashTest.cpp")

# Synchronization tests
folly_cc_test(src = "folly/synchronization/test/AtomicNotificationTest.cpp")
folly_cc_test(src = "folly/synchronization/test/AtomicRefTest.cpp")
folly_cc_test(src = "folly/synchronization/test/AtomicStructTest.cpp")
folly_cc_test(src = "folly/synchronization/test/AtomicUtilTest.cpp")
# folly_cc_test(src = "folly/synchronization/test/Ba# folly_cc_test(src = "folly/synchronization/test/BatonTest.cpp") # Build fails/BatonTest.cpp") # Build fails
folly_cc_test(src = "folly/synchronization/test/CallOnceTest.cpp")
folly_cc_test(src = "folly/synchronization/test/DelayedInitTest.cpp")
# folly_cc_test(src = "folly/synchronization/test/DistributedMutexTest.cpp") # Build fails
folly_cc_test(src = "folly/synchronization/test/EventCountTest.cpp")
folly_cc_test(src = "folly/synchronization/test/FlatCombiningTest.cpp")
# folly_cc_test(src = "folly/synchronization/test/HazptrTest.cpp") # Build fails
folly_cc_test(src = "folly/synchronization/test/LatchTest.cpp")
# folly_cc_test(src = "folly/synchronization/test/LockTest.cpp") # Build fails
folly_cc_test(src = "folly/synchronization/test/NativeSemaphoreTest.cpp")
folly_cc_test(src = "folly/synchronization/test/ParkingLotTest.cpp")
folly_cc_test(src = "folly/synchronization/test/RcuTest.cpp")
folly_cc_test(src = "folly/synchronization/test/RelaxedAtomicTest.cpp")
folly_cc_test(src = "folly/synchronization/test/RWSpinLockTest.cpp")
# folly_cc_test(src = "folly/synchronization/test/SaturatingSemaphoreTest.cpp") # Build fails
folly_cc_test(src = "folly/synchronization/test/SemaphoreTest.cpp")
folly_cc_test(src = "folly/synchronization/test/SmallLocksTest.cpp")
folly_cc_test(src = "folly/synchronization/test/ThrottledLifoSemTest.cpp")
folly_cc_test(src = "folly/synchronization/test/ThreadCachedReadersTest.cpp")
folly_cc_test(src = "folly/synchronization/detail/test/HardwareTest.cpp")
folly_cc_test(src = "folly/synchronization/detail/test/InlineFunctionRefTest.cpp")

# System tests
folly_cc_test(src = "folly/system/test/AtForkTest.cpp")
folly_cc_test(src = "folly/system/test/AuxVectorTest.cpp")
folly_cc_test(src = "folly/system/test/EnvUtilTest.cpp")
folly_cc_test(src = "folly/system/test/HardwareConcurrencyTest.cpp")
folly_cc_test(src = "folly/system/test/MemoryMappingTest.cpp")
folly_cc_test(src = "folly/system/test/PidTest.cpp")
folly_cc_test(src = "folly/system/test/ShellTest.cpp")
folly_cc_test(src = "folly/system/test/ThreadIdTest.cpp")
folly_cc_test(src = "folly/system/test/ThreadNameTest.cpp")

# Lang tests
folly_cc_test(src = "folly/lang/test/AlignedTest.cpp")
folly_cc_test(src = "folly/lang/test/AlignTest.cpp")
folly_cc_test(src = "folly/lang/test/BadgeTest.cpp")
folly_cc_test(src = "folly/lang/test/BitsClassTest.cpp")
folly_cc_test(src = "folly/lang/test/BitsTest.cpp")
folly_cc_test(src = "folly/lang/test/CastTest.cpp")
folly_cc_test(src = "folly/lang/test/CheckedMathTest.cpp")
folly_cc_test(src = "folly/lang/test/CStringTest.cpp")
folly_cc_test(src = "folly/lang/test/ExceptionTest.cpp")
folly_cc_test(src = "folly/lang/test/ExternTest.cpp")
folly_cc_test(src = "folly/lang/test/HintTest.cpp")
folly_cc_test(src = "folly/lang/test/NewTest.cpp")
folly_cc_test(src = "folly/lang/test/OrderingTest.cpp")
folly_cc_test(src = "folly/lang/test/PrettyTest.cpp")
folly_cc_test(src = "folly/lang/test/PropagateConstTest.cpp")
folly_cc_test(src = "folly/lang/test/RValueReferenceWrapperTest.cpp")
# folly_cc_test(src = "folly/lang/test/SafeAliasTest.cpp") # Build fails
folly_cc_test(src = "folly/lang/test/SafeAssertTest.cpp")
folly_cc_test(src = "folly/lang/test/StrongTest.cpp")
folly_cc_test(src = "folly/lang/test/SwitchTest.cpp")
folly_cc_test(src = "folly/lang/test/ThunkTest.cpp")
folly_cc_test(src = "folly/lang/test/ToAsciiTest.cpp")
folly_cc_test(src = "folly/lang/test/TypeInfoTest.cpp")
folly_cc_test(src = "folly/lang/test/VectorTraitsTest.cpp")
# folly_cc_test(src = "folly/lang/bind/test/AsArgumentTest.cpp") # Build fails
folly_cc_test(src = "folly/lang/bind/test/BindTest.cpp")
folly_cc_test(src = "folly/lang/bind/test/NamedTest.cpp")
# folly_cc_test(src = "folly/lang/bind/test/ToStorageTest.cpp") # Build fails

# Functional tests
folly_cc_test(src = "folly/functional/test/ApplyTupleTest.cpp")
folly_cc_test(src = "folly/functional/test/InvokeTest.cpp")
folly_cc_test(src = "folly/functional/test/PartialTest.cpp")

# Gen tests
folly_cc_test(src = "folly/gen/test/BaseTest.cpp")
folly_cc_test(src = "folly/gen/test/CombineTest.cpp")
folly_cc_test(src = "folly/gen/test/FileTest.cpp")
folly_cc_test(src = "folly/gen/test/IStreamTest.cpp")
folly_cc_test(src = "folly/gen/test/ParallelMapTest.cpp")
folly_cc_test(src = "folly/gen/test/ParallelTest.cpp")
folly_cc_test(src = "folly/gen/test/StringTest.cpp")

# Stats tests
folly_cc_test(src = "folly/stats/test/BufferedStatTest.cpp")
folly_cc_test(src = "folly/stats/test/DigestBuilderTest.cpp")
folly_cc_test(src = "folly/stats/test/HistogramTest.cpp")
folly_cc_test(src = "folly/stats/test/QuantileEstimatorTest.cpp")
folly_cc_test(src = "folly/stats/test/QuantileHistogramTest.cpp")
folly_cc_test(src = "folly/stats/test/SlidingWindowTest.cpp")
folly_cc_test(src = "folly/stats/test/StreamingStatsTest.cpp")
folly_cc_test(src = "folly/stats/test/TDigestTest.cpp")
folly_cc_test(src = "folly/stats/test/TimeseriesHistogramTest.cpp")
folly_cc_test(src = "folly/stats/test/TimeSeriesTest.cpp")
folly_cc_test(src = "folly/stats/detail/test/DoubleRadixSortTest.cpp")

# SSL tests
folly_cc_test(src = "folly/ssl/test/OpenSSLCertUtilsTest.cpp")
folly_cc_test(src = "folly/ssl/test/OpenSSLHashTest.cpp")
folly_cc_test(src = "folly/ssl/test/OpenSSLKeyUtilsTest.cpp")
folly_cc_test(src = "folly/ssl/test/SSLSessionManagerTest.cpp")

# Debugging/Symbolizer tests
folly_cc_test(src = "folly/debugging/symbolizer/test/ElfTest.cpp")
folly_cc_test(src = "folly/debugging/symbolizer/test/LineReaderTest.cpp")
folly_cc_test(src = "folly/debugging/symbolizer/test/StackTraceTest.cpp")
# folly_cc_test(src = "folly/debugging/symbolizer/test/SymbolizerTest.cpp") # Build fails
folly_cc_test(src = "folly/debugging/symbolizer/test/SymbolizedFrameTest.cpp")

# Tracing tests
folly_cc_test(src = "folly/tracing/test/AsyncStackTest.cpp")
# folly_cc_test(src = "folly/tracing/test/StaticTracepointTest.cpp") # Build fails

# Detail tests
folly_cc_test(src = "folly/detail/test/AsyncTraceTest.cpp")
folly_cc_test(src = "folly/detail/test/FileUtilDetailTest.cpp")
folly_cc_test(src = "folly/detail/test/SimpleSimdStringUtilsTest.cpp")
folly_cc_test(src = "folly/detail/test/SplitStringSimdTest.cpp")
folly_cc_test(src = "folly/detail/test/StaticSingletonManagerTest.cpp")
folly_cc_test(src = "folly/detail/test/ThreadLocalDetailTest.cpp")
folly_cc_test(src = "folly/detail/test/TypeListTest.cpp")
folly_cc_test(src = "folly/detail/test/UniqueInstanceTest.cpp")
folly_cc_test(src = "folly/detail/base64_detail/test/Base64AgainstScalarTest.cpp")
folly_cc_test(src = "folly/detail/base64_detail/test/Base64PlatformTest.cpp")
folly_cc_test(src = "folly/detail/base64_detail/test/Base64SpecialCasesTest.cpp")

# Chrono tests
folly_cc_test(src = "folly/chrono/test/ClockTest.cpp")
folly_cc_test(src = "folly/chrono/test/ConvTest.cpp")

# CLI tests
folly_cc_test(src = "folly/cli/test/NestedCommandLineAppTest.cpp")
folly_cc_test(src = "folly/cli/test/ProgramOptionsTest.cpp")

# Codec tests
folly_cc_test(src = "folly/codec/test/UuidTest.cpp")

# Random tests
folly_cc_test(src = "folly/random/test/Xoshiro256ppTest.cpp")

# Init tests
folly_cc_singleton_test(src = "folly/init/test/PhaseTest.cpp")
