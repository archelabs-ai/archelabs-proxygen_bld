# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

"""
BUILD.bazel overlay for liburing (io_uring support library).

This file is applied on top of the liburing source via build_file attribute
in http_archive. liburing provides helpers for the Linux kernel io_uring API.

Based on BCR build at:
https://github.com/bazelbuild/bazel-central-registry/tree/main/modules/liburing/2.10
"""

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

# Export license
exports_files(["LICENSE", "COPYING"])

# ============================================================================
# Pre-generated headers from configure
# ============================================================================

# Copy config-host.h from thirdparty/liburing
genrule(
    name = "config_host_h",
    srcs = ["@//thirdparty/liburing:config-host.h"],
    outs = ["config-host.h"],
    cmd = "cp $< $@",
)

# Copy compat.h from thirdparty/liburing to proper location
genrule(
    name = "compat_h",
    srcs = ["@//thirdparty/liburing:compat.h"],
    outs = ["src/include/liburing/compat.h"],
    cmd = "cp $< $@",
)

# Copy io_uring_version.h from thirdparty/liburing to proper location
genrule(
    name = "io_uring_version_h",
    srcs = ["@//thirdparty/liburing:io_uring_version.h"],
    outs = ["src/include/liburing/io_uring_version.h"],
    cmd = "cp $< $@",
)

# ============================================================================
# Main liburing library
# ============================================================================

cc_library(
    name = "uring",
    srcs = [
        # Generated config header (included via -include)
        ":config_host_h",
        # Generated headers
        ":compat_h",
        ":io_uring_version_h",
        # Source files
        "src/queue.c",
        "src/register.c",
        "src/setup.c",
        "src/syscall.c",
        "src/version.c",
        # Note: sanitize.c is only for sanitizer builds (provides non-inline versions)
        # Note: nolibc.c and ffi.c are excluded (nolibc for builds without libc, ffi for FFI bindings)
        # Internal headers (needed by .c files)
        "src/int_flags.h",
        "src/lib.h",
        "src/setup.h",
        "src/syscall.h",
    ] + glob([
        "src/arch/**/*.h",
    ]),
    hdrs = glob([
        "src/include/**/*.h",
    ], exclude = [
        # These are generated
        "src/include/liburing/compat.h",
        "src/include/liburing/io_uring_version.h",
    ]) + [
        # Add generated headers as public hdrs too
        ":compat_h",
        ":io_uring_version_h",
    ],
    # cflags aligned with upstream:
    # https://github.com/axboe/liburing/blob/master/src/Makefile
    copts = [
        "-D_GNU_SOURCE",
        "-D_LARGEFILE_SOURCE",
        "-D_FILE_OFFSET_BITS=64",
        "-DLIBURING_INTERNAL",
        "-O3",
        "-Wall",
        "-Wextra",
        "-fno-stack-protector",
        "-include",
        "$(GENDIR)/external/+_repo_rules+liburing_repo/config-host.h",
        # Suppress warnings
        "-Wno-unused-parameter",
        "-Wno-sign-compare",
    ],
    includes = ["src/include"],
    # Note: "src" is NOT in includes to avoid exposing internal headers like syscall.h
    # which can conflict with system headers
    # Note: nolibc.c and ffi.c are intentionally excluded:
    # - nolibc.c: for builds without libc (we use --use-libc)
    # - ffi.c: for FFI bindings (not needed for C/C++ usage)
)

alias(
    name = "liburing",
    actual = ":uring",
)
