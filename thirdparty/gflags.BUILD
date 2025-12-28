# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Build file for gflags/gflags - https://github.com/gflags/gflags
# Uses system gflags library

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "gflags",
    hdrs = glob(
        ["src/gflags/*.h"],
        allow_empty = True,
    ),
    includes = ["src"],
    linkopts = ["-lgflags"],
    visibility = ["//visibility:public"],
)
