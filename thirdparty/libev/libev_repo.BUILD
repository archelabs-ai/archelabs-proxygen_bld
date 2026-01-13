# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

"""
BUILD.bazel overlay for libev (high-performance event loop library).

This file is applied on top of the libev source via build_file attribute
in http_archive. libev is a high-performance event loop library used by
mvfst for LibevQuicEventBase.

Website: http://software.schmorp.de/pkg/libev.html
"""

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

# Export license
exports_files(["LICENSE"])

# Pre-generated config.h for Linux
genrule(
    name = "config_h",
    srcs = ["@al_proxygen//thirdparty/libev:config.h"],
    outs = ["config.h"],
    cmd = "cp $< $@",
)

cc_library(
    name = "libev",
    srcs = [
        "ev.c",
        # event.c provides libevent compatibility - optional
        # "event.c",
    ],
    hdrs = [
        "ev.h",
        "ev++.h",
        "ev_epoll.c",
        "ev_iouring.c",
        "ev_kqueue.c",
        "ev_linuxaio.c",
        "ev_poll.c",
        "ev_port.c",
        "ev_select.c",
        "ev_vars.h",
        "ev_win32.c",
        "ev_wrap.h",
        # libevent compatibility header - optional
        # "event.h",
        ":config_h",
    ],
    copts = [
        "-std=c11",
        "-DHAVE_CONFIG_H",
        "-DEV_STANDALONE=1",
        # Performance optimizations
        "-DEV_USE_EPOLL=1",
        "-DEV_USE_POLL=1",
        "-DEV_USE_SELECT=1",
        "-DEV_USE_EVENTFD=1",
        "-DEV_USE_SIGNALFD=1",
        "-DEV_USE_INOTIFY=1",
        "-DEV_USE_TIMERFD=1",
        # Linux-specific
        "-DEV_USE_LINUXAIO=1",
        # Disable backends not available on Linux
        "-DEV_USE_KQUEUE=0",
        "-DEV_USE_PORT=0",
        # Multi-threading support
        "-DEV_MULTIPLICITY=1",
        # Enable POSIX features for lstat, syscall
        "-D_DEFAULT_SOURCE",
        "-D_GNU_SOURCE",
        # Suppress warnings
        "-Wno-unused-value",
        "-Wno-comment",
        "-Wno-sign-compare",
        "-Wno-implicit-function-declaration",
        "-Wno-dangling-else",
        "-Wno-return-type",
        "-Wno-parentheses",
    ],
    includes = ["."],
    linkopts = [
        "-lm",
        "-lpthread",
    ],
)
