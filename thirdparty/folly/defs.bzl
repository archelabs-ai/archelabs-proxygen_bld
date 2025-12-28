# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

"""Bazel macros for folly tests."""

load("@rules_cc//cc:defs.bzl", "cc_library", "cc_test")

FOLLY_TEST_COPTS = [
    "-std=c++20",
    "-fcoroutines",
    "-pthread",
    "-Wno-deprecated-declarations",
    "-Wno-sign-compare",
]

def folly_test_main_library():
    """Create a cc_library target for the folly test main that calls folly::Init.

    This must be called in the folly_repo.BUILD file to create the :folly_test_main target.
    Tests that use folly singletons should depend on this instead of @googletest//:gtest_main.
    """
    cc_library(
        name = "folly_test_main",
        srcs = ["@//thirdparty/folly:folly_test_main.cpp"],
        deps = [
            ":folly",
            "@googletest//:gtest",
        ],
        copts = FOLLY_TEST_COPTS,
        alwayslink = True,
    )

def folly_cc_test(src, deps = [], **kwargs):
    """Macro for folly unit tests. Derives name from source file path to ensure uniqueness.

    Args:
        src: Source file path (e.g., "folly/foo/test/BarTest.cpp")
        deps: Additional dependencies beyond folly and gtest
        **kwargs: Additional arguments passed to cc_test
    """
    # Create unique name from path: "folly/foo/test/BarTest.cpp" -> "foo_BarTest"
    # This avoids collisions like coro/CollectTest vs futures/CollectTest
    parts = src.split("/")
    # Remove "folly" prefix, "test" directories, and ".cpp" suffix
    meaningful_parts = [p for p in parts if p not in ["folly", "test", "tests"] and not p.endswith(".cpp")]
    test_name = parts[-1].replace(".cpp", "")
    if meaningful_parts:
        name = "_".join(meaningful_parts) + "_" + test_name
    else:
        name = test_name
    cc_test(
        name = name,
        srcs = [src],
        copts = FOLLY_TEST_COPTS,
        deps = [":folly", "@googletest//:gtest_main"] + deps,
        **kwargs
    )

def folly_cc_singleton_test(src, deps = [], **kwargs):
    """Macro for folly tests that use singletons and require folly::Init.

    These tests need folly::Init to be called before the test runs to properly
    initialize the singleton registry. This macro uses a custom test main
    instead of gtest_main.

    Args:
        src: Source file path (e.g., "folly/foo/test/BarTest.cpp")
        deps: Additional dependencies beyond folly and gtest
        **kwargs: Additional arguments passed to cc_test
    """
    # Create unique name from path: "folly/foo/test/BarTest.cpp" -> "foo_BarTest"
    # This avoids collisions like coro/CollectTest vs futures/CollectTest
    parts = src.split("/")
    # Remove "folly" prefix, "test" directories, and ".cpp" suffix
    meaningful_parts = [p for p in parts if p not in ["folly", "test", "tests"] and not p.endswith(".cpp")]
    test_name = parts[-1].replace(".cpp", "")
    if meaningful_parts:
        name = "_".join(meaningful_parts) + "_" + test_name
    else:
        name = test_name
    cc_test(
        name = name,
        srcs = [src],
        copts = FOLLY_TEST_COPTS,
        deps = [":folly", ":folly_test_main", "@googletest//:gtest"] + deps,
        **kwargs
    )
