# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Build file for google/glog - https://github.com/google/glog
# This build file expects glog to be pre-installed OR links system glog

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "glog",
    hdrs = glob(
        ["src/glog/*.h"],
        allow_empty = True,
    ),
    includes = ["src"],
    linkopts = ["-lglog"],
    visibility = ["//visibility:public"],
    deps = ["@gflags"],
)
