# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

"""Bazel macros for mvfst tests."""

load("@rules_cc//cc:defs.bzl", "cc_test")

MVFST_TEST_COPTS = [
    "-std=c++20",
    "-fcoroutines",
    "-pthread",
    "-Wno-deprecated-declarations",
    "-Wno-sign-compare",
]

def mvfst_cc_test(src, deps = [], **kwargs):
    """Macro for mvfst unit tests. Derives name from source file path to ensure uniqueness.

    Args:
        src: Source file path (e.g., "quic/foo/test/BarTest.cpp")
        deps: Additional dependencies beyond quic, quic_test_lib, quic_test_main, and gtest
        **kwargs: Additional arguments passed to cc_test
    """
    # Create unique name from path: "quic/foo/test/BarTest.cpp" -> "foo_BarTest"
    parts = src.split("/")
    meaningful_parts = [p for p in parts if p not in ["quic", "test", "tests"] and not p.endswith(".cpp")]
    test_name = parts[-1].replace(".cpp", "")
    if meaningful_parts:
        name = "_".join(meaningful_parts) + "_" + test_name
    else:
        name = test_name
    cc_test(
        name = name,
        srcs = [src],
        copts = MVFST_TEST_COPTS,
        deps = [":quic", ":quic_test_lib", ":quic_test_main", "@googletest//:gtest"] + deps,
        **kwargs
    )
