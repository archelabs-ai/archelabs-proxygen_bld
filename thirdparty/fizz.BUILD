# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Build file for facebookincubator/fizz - https://github.com/facebookincubator/fizz

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

# Generate fizz-config.h
genrule(
    name = "fizz_config_h",
    outs = ["fizz/fizz-config.h"],
    cmd = """
cat > $@ << 'EOFCONFIG'
#pragma once

#define FIZZ_HAVE_LIBAEGIS 0
#define FIZZ_HAVE_SODIUM 0
#define FIZZ_HAVE_OQS 0
#define FIZZ_CERTIFICATE_USE_OPENSSL_CERT 1

#if !defined(FIZZ_ENABLE_CONTEXT_COMPATIBILITY_CHECKS)
#if defined(NDEBUG)
#define FIZZ_ENABLE_CONTEXT_COMPATIBILITY_CHECKS 0
#else
#define FIZZ_ENABLE_CONTEXT_COMPATIBILITY_CHECKS 1
#endif
#endif

#define FIZZ_CONTEXT_VALIDATION_SHOULD_CHECK_CIPHER(x) (true)

// Default factory configuration
#define FIZZ_DEFAULT_FACTORY_HEADER <fizz/protocol/MultiBackendFactory.h>
#define FIZZ_DEFAULT_FACTORY ::fizz::MultiBackendFactory
EOFCONFIG
""",
)

cc_library(
    name = "fizz",
    hdrs = glob(
        ["fizz/**/*.h"],
        allow_empty = True,
    ) + [":fizz_config_h"],
    includes = [
        ".",
        "$(GENDIR)/external/+_repo_rules+fizz",
    ],
    copts = [
        "-Iexternal/+_repo_rules+fizz",
        "-I$(GENDIR)/external/+_repo_rules+fizz",
    ],
    linkopts = [
        "-L/usr/local/lib",
        "-lfizz",
        "-lssl",
        "-lcrypto",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@folly",
    ],
)
