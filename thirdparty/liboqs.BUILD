# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Build file for open-quantum-safe/liboqs - https://github.com/open-quantum-safe/liboqs

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

# Generate oqsconfig.h
genrule(
    name = "oqsconfig_h",
    outs = ["include/oqs/oqsconfig.h"],
    cmd = """
cat > $@ << 'EOF'
#ifndef OQS_CONFIG_H
#define OQS_CONFIG_H

#define OQS_VERSION_TEXT "0.12.0"
#define OQS_COMPILE_BUILD_TARGET "x86_64-Linux"
#define OQS_DIST_BUILD 1
#define OQS_BUILD_ONLY_LIB 1

#define OQS_USE_OPENSSL 1
#define OQS_USE_AES_OPENSSL 1
#define OQS_USE_SHA2_OPENSSL 1
#define OQS_USE_SHA3_OPENSSL 0

// Enable Kyber and ML-KEM as specified in the cmake defines
#define OQS_ENABLE_KEM_kyber_512 1
#define OQS_ENABLE_KEM_kyber_768 1
#define OQS_ENABLE_KEM_kyber_1024 1
#define OQS_ENABLE_KEM_ml_kem_512 1
#define OQS_ENABLE_KEM_ml_kem_768 1
#define OQS_ENABLE_KEM_ml_kem_1024 1

// Disable signature schemes for minimal build
#define OQS_ENABLE_SIG_dilithium_2 0
#define OQS_ENABLE_SIG_dilithium_3 0
#define OQS_ENABLE_SIG_dilithium_5 0
#define OQS_ENABLE_SIG_ml_dsa_44 0
#define OQS_ENABLE_SIG_ml_dsa_65 0
#define OQS_ENABLE_SIG_ml_dsa_87 0
#define OQS_ENABLE_SIG_falcon_512 0
#define OQS_ENABLE_SIG_falcon_1024 0
#define OQS_ENABLE_SIG_sphincs 0

// CPU feature detection
#define OQS_USE_CPU_EXTENSIONS 1
#define OQS_USE_AVX2_INSTRUCTIONS 1
#define OQS_USE_AVX512_INSTRUCTIONS 1
#define OQS_USE_AES_INSTRUCTIONS 1

#define ARCH_X86_64 1

#endif
EOF
""",
)

cc_library(
    name = "liboqs",
    srcs = glob([
        "src/**/*.c",
        "src/**/*.h",
    ], exclude = [
        "src/**/*_test.c",
        "src/**/test_*.c",
        "tests/**",
    ]),
    hdrs = [
        "src/oqs.h",
    ] + [":oqsconfig_h"],
    includes = [
        "src",
        "include",
    ],
    copts = [
        "-DOQS_BUILD",
        "-I$(GENDIR)/external/liboqs/include",
    ],
    linkstatic = True,
)
