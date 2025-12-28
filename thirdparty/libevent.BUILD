# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Build file for libevent/libevent - https://github.com/libevent/libevent
# Uses system libevent library

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "libevent",
    hdrs = glob(
        ["include/**/*.h"],
        allow_empty = True,
    ),
    includes = ["include"],
    linkopts = ["-levent"],
    visibility = ["//visibility:public"],
)
