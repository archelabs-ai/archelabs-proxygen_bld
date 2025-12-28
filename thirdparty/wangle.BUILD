# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Build file for facebook/wangle - https://github.com/facebook/wangle
# This build file expects wangle to be pre-installed on the system.

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "wangle",
    hdrs = glob(
        ["wangle/**/*.h"],
        allow_empty = True,
    ),
    includes = ["."],
    linkopts = [
        "-L/usr/local/lib",
        "-lwangle",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@fizz",
        "@folly",
    ],
)
