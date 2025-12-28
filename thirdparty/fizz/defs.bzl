# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

"""Bazel macros for fizz tests."""

load("@rules_cc//cc:defs.bzl", "cc_test")

FIZZ_TEST_COPTS = [
    "-std=c++20",
    "-fcoroutines",
    "-pthread",
    "-Wno-deprecated-declarations",
    "-Wno-sign-compare",
]

def fizz_cc_test(src, deps = [], **kwargs):
    """Macro for fizz unit tests. Derives name from source file path to ensure uniqueness.

    Args:
        src: Source file path (e.g., "fizz/foo/test/BarTest.cpp")
        deps: Additional dependencies beyond fizz, fizz_test_lib, and gtest
        **kwargs: Additional arguments passed to cc_test
    """
    # Create unique name from path: "fizz/foo/test/BarTest.cpp" -> "foo_BarTest"
    parts = src.split("/")
    meaningful_parts = [p for p in parts if p not in ["fizz", "test", "tests"] and not p.endswith(".cpp")]
    test_name = parts[-1].replace(".cpp", "")
    if meaningful_parts:
        name = "_".join(meaningful_parts) + "_" + test_name
    else:
        name = test_name
    cc_test(
        name = name,
        srcs = [src],
        copts = FIZZ_TEST_COPTS,
        deps = [":fizz", ":fizz_test_lib", "@googletest//:gtest_main"] + deps,
        **kwargs
    )
