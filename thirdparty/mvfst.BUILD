# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Build file for facebook/mvfst - https://github.com/facebook/mvfst

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "mvfst",
    hdrs = glob(
        [
            "quic/**/*.h",
            "quic/**/*.hpp",
        ],
        allow_empty = True,
    ),
    includes = ["."],
    linkopts = [
        "-L/usr/local/lib",
        "-lmvfst_server",
        "-lmvfst_client",
        "-lmvfst_transport",
        "-lmvfst_codec",
        "-lmvfst_state_machine",
        "-lmvfst_handshake",
        "-lmvfst_dsr_frontend",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@fizz",
        "@folly",
    ],
)
