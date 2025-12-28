# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Build file for pre-built external libraries in extlibs/
# These libraries are built by extlibs/build_extlibs.sh using CMake/Autotools

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

# ============================================================================
# Core system libraries
# ============================================================================

# gflags and glog are provided by BCR (Bazel Central Registry)
# Using glog 0.6.0 which is compatible with both Bazel and CMake builds

cc_library(
    name = "libevent",
    hdrs = glob([
        "include/event.h",
        "include/evhttp.h",
        "include/evdns.h",
        "include/evrpc.h",
        "include/evutil.h",
        "include/event2/**/*.h",
    ]),
    includes = ["include"],
    srcs = [
        "lib/libevent.so",
        "lib/libevent_core.so",
        "lib/libevent_extra.so",
        "lib/libevent_openssl.so",
        "lib/libevent_pthreads.so",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "libsodium",
    hdrs = glob([
        "include/sodium.h",
        "include/sodium/**/*.h",
    ]),
    includes = ["include"],
    srcs = ["lib/libsodium.so"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "cares",
    hdrs = glob(["include/ares*.h"]),
    includes = ["include"],
    srcs = ["lib/libcares.so"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "snappy",
    hdrs = glob(["include/snappy*.h"]),
    includes = ["include"],
    srcs = ["lib/libsnappy.a"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "liboqs",
    hdrs = glob(["include/oqs/**/*.h"]),
    includes = ["include"],
    srcs = ["lib/liboqs.so"],
    visibility = ["//visibility:public"],
)

# ============================================================================
# Facebook Libraries
# ============================================================================

cc_library(
    name = "folly",
    hdrs = glob(["include/folly/**/*.h"]),
    includes = ["include"],
    srcs = ["lib/libfolly.so"],
    visibility = ["//visibility:public"],
    deps = [
        ":libevent",
        ":libsodium",
        ":snappy",
        "@gflags",
        "@glog",
        "@boost.context",
        "@boost.filesystem",
        "@boost.program_options",
        "@boost.regex",
        "@boost.system",
        "@boost.thread",
        "@double-conversion",
        "@fmt",
        "@lz4",
        "@zlib",
        "@zstd",
    ],
    linkopts = [
        "-lssl",
        "-lcrypto",
        "-lpthread",
        "-ldl",
        "-lrt",
    ],
)

cc_library(
    name = "folly_test_util",
    hdrs = glob(["include/folly/test/**/*.h"]),
    includes = ["include"],
    srcs = ["lib/libfolly_test_util.so"],
    visibility = ["//visibility:public"],
    deps = [
        ":folly",
        "@googletest//:gtest",
    ],
)

cc_library(
    name = "fizz",
    hdrs = glob(["include/fizz/**/*.h"]),
    includes = ["include"],
    srcs = ["lib/libfizz.so"],
    visibility = ["//visibility:public"],
    deps = [
        ":folly",
        ":libsodium",
    ],
    linkopts = [
        "-lssl",
        "-lcrypto",
    ],
)

cc_library(
    name = "wangle",
    hdrs = glob(["include/wangle/**/*.h"]),
    includes = ["include"],
    srcs = ["lib/libwangle.so"],
    visibility = ["//visibility:public"],
    deps = [
        ":fizz",
        ":folly",
    ],
)

cc_library(
    name = "mvfst",
    hdrs = glob([
        "include/quic/**/*.h",
        "include/quic/**/*.hpp",
    ]),
    includes = ["include"],
    srcs = glob(["lib/libmvfst*.so"]),
    visibility = ["//visibility:public"],
    deps = [
        ":fizz",
        ":folly",
    ],
)
