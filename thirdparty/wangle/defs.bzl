# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the Apache License, Version 2.0.
# See the LICENSE file in the root directory of this source tree.

"""Bazel macros for wangle tests."""

load("@rules_cc//cc:defs.bzl", "cc_test")

WANGLE_TEST_COPTS = [
    "-std=c++20",
    "-fcoroutines",
    "-pthread",
    "-Wno-deprecated-declarations",
    "-Wno-sign-compare",
]

def wangle_cc_test(src, deps = [], **kwargs):
    """Macro for wangle unit tests. Derives name from source file path to ensure uniqueness.

    Args:
        src: Source file path (e.g., "wangle/foo/test/BarTest.cpp")
        deps: Component-specific dependencies (e.g., [":acceptor", ":acceptor_test_lib"])
        **kwargs: Additional arguments passed to cc_test
    """
    # Create unique name from path: "wangle/foo/test/BarTest.cpp" -> "foo_BarTest"
    parts = src.split("/")
    meaningful_parts = [p for p in parts if p not in ["wangle", "test", "tests"] and not p.endswith(".cpp")]
    test_name = parts[-1].replace(".cpp", "")
    if meaningful_parts:
        name = "_".join(meaningful_parts) + "_" + test_name
    else:
        name = test_name
    cc_test(
        name = name,
        srcs = [src],
        copts = WANGLE_TEST_COPTS,
        # gmock is included in gtest in BCR module
        deps = [":test_main", "@googletest//:gtest"] + deps,
        **kwargs
    )
