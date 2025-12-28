# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Build file for facebook/folly - https://github.com/facebook/folly

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

# Generate folly-config.h
genrule(
    name = "folly_config_h",
    outs = ["folly/folly-config.h"],
    cmd = """
cat > $@ << 'EOFCONFIG'
#pragma once

#define FOLLY_HAVE_PTHREAD 1
#define FOLLY_HAVE_PTHREAD_ATFORK 1
#define FOLLY_HAVE_LIBGFLAGS 1
#define FOLLY_HAVE_LIBGLOG 1
#define FOLLY_HAVE_LIBEVENT 1
#define FOLLY_HAVE_LIBZ 1
#define FOLLY_HAVE_LIBLZ4 1
#define FOLLY_HAVE_LIBSNAPPY 1
#define FOLLY_HAVE_LIBZSTD 1
#define FOLLY_HAVE_LIBSODIUM 1
#define FOLLY_HAVE_LIBDOUBLE_CONVERSION 1
#define FOLLY_HAVE_LIBBOOST_CONTEXT 1
#define FOLLY_HAVE_LIBBOOST_FILESYSTEM 1
#define FOLLY_HAVE_LIBBOOST_PROGRAM_OPTIONS 1
#define FOLLY_HAVE_LIBBOOST_REGEX 1
#define FOLLY_HAVE_LIBBOOST_SYSTEM 1
#define FOLLY_HAVE_LIBBOOST_THREAD 1
#define FOLLY_USE_JEMALLOC 0

#define FOLLY_HAVE_ACCEPT4 1
#define FOLLY_HAVE_CLOCK_GETTIME 1
#define FOLLY_HAVE_GETRANDOM 1
#define FOLLY_HAVE_IFUNC 1
#define FOLLY_HAVE_INT128_T 1
#define FOLLY_HAVE_LIBC_MEMRCHR 1
#define FOLLY_HAVE_LINUX_VDSO 1
#define FOLLY_HAVE_MALLOC_USABLE_SIZE 1
#define FOLLY_HAVE_MEMRCHR 1
#define FOLLY_HAVE_PIPE2 1
#define FOLLY_HAVE_PREADV 1
#define FOLLY_HAVE_PWRITEV 1
#define FOLLY_HAVE_RECVMMSG 1
#define FOLLY_HAVE_SENDMMSG 1
#define FOLLY_HAVE_STD_IS_TRIVIALLY_COPYABLE 1
#define FOLLY_HAVE_WEAK_SYMBOLS 1
#define FOLLY_HAVE_UNALIGNED_ACCESS 1
#define FOLLY_HAVE_VLA 1
#define FOLLY_HAVE_SHADOW_LOCAL_WARNINGS 1
#define FOLLY_HAVE_DWARF 0
#define FOLLY_HAVE_ELF 1

#define FOLLY_HAVE_EXTRANDOM_SFMT19937 0

#define FOLLY_HAVE_BITS_CXXCONFIG_H 1
#define FOLLY_HAVE_FEATURES_H 1
#define FOLLY_HAVE_LINUX_MEMBARRIER_H 1
#define FOLLY_HAVE_SCHED_H 1

#define FOLLY_SSE 2
#define FOLLY_SSE_MINOR 0
#define FOLLY_NEON 0
#define FOLLY_X64 1

#define FOLLY_HAVE_LIBUNWIND 1
#define FOLLY_HAVE_BACKTRACE 1

#define FOLLY_LIBRARY_SANITIZE_ADDRESS 0
#define FOLLY_CPLUSPLUS __cplusplus

#define FOLLY_F14_VECTOR_INTRINSICS_AVAILABLE 1
#define FOLLY_AARCH64 0

#define FOLLY_MOBILE 0
#define FOLLY_HAVE_COROUTINES 1

#define FOLLY_HAVE_OPENSSL_ASN1_TIME_DIFF 1
#define FOLLY_HAVE_LIBURING 0

#define FOLLY_HAVE_FILESYSTEM 1
#define FOLLY_HAVE_ANON_FILE 1
EOFCONFIG
""",
)

cc_library(
    name = "folly",
    hdrs = glob(
        ["folly/**/*.h"],
        allow_empty = True,
    ) + [":folly_config_h"],
    includes = ["."],
    copts = [
        "-I$(GENDIR)/external/folly",
    ],
    linkopts = [
        "-L/usr/local/lib",
        "-lfolly",
        "-lssl",
        "-lcrypto",
        "-lpthread",
        "-ldl",
        "-lrt",
        "-lfmt",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@boost.context",
        "@boost.filesystem",
        "@boost.program_options",
        "@boost.regex",
        "@boost.system",
        "@boost.thread",
        "@double-conversion//:double-conversion",
        "@fmt",
        "@gflags//:gflags",
        "@glog//:glog",
        "@libevent//:event",
    ],
)

# Folly testing support
cc_library(
    name = "folly_test_util",
    hdrs = glob(
        [
            "folly/test/*.h",
            "folly/io/async/test/*.h",
        ],
        allow_empty = True,
    ),
    deps = [
        ":folly",
        "@googletest//:gtest",
    ],
    visibility = ["//visibility:public"],
)
