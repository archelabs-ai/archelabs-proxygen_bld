# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Build file for google/googletest - https://github.com/google/googletest

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "gtest",
    srcs = glob(
        ["googletest/src/*.cc"],
        exclude = ["googletest/src/gtest-all.cc"],
    ),
    hdrs = glob([
        "googletest/include/**/*.h",
        "googletest/src/*.h",
    ]),
    copts = [
        "-std=c++17",
    ],
    includes = [
        "googletest",
        "googletest/include",
    ],
    linkopts = ["-pthread"],
    linkstatic = True,
)

cc_library(
    name = "gtest_main",
    srcs = ["googletest/src/gtest_main.cc"],
    deps = [":gtest"],
    linkstatic = True,
)

cc_library(
    name = "gmock",
    srcs = glob(
        ["googlemock/src/*.cc"],
        exclude = ["googlemock/src/gmock-all.cc"],
    ),
    hdrs = glob([
        "googlemock/include/**/*.h",
        "googlemock/src/*.h",
    ]),
    copts = [
        "-std=c++17",
    ],
    includes = [
        "googlemock",
        "googlemock/include",
    ],
    linkopts = ["-pthread"],
    linkstatic = True,
    deps = [":gtest"],
)

cc_library(
    name = "gmock_main",
    srcs = ["googlemock/src/gmock_main.cc"],
    deps = [":gmock"],
    linkstatic = True,
)
