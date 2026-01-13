# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

"""
BUILD.bazel overlay for the fizz git repository.

This file is applied on top of the fizz repo via build_file attribute
in git_repository. It builds fizz as a monolithic library.

Fizz is Facebook's implementation of TLS 1.3.
"""

load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library", "cc_test")
load("@al_proxygen//thirdparty/fizz:defs.bzl", "fizz_cc_test", "FIZZ_TEST_COPTS")

package(default_visibility = ["//visibility:public"])

# Export source files
exports_files([
    "LICENSE",
    "fizz/fizz-config.h.in",
])

# ============================================================================
# Configuration header
# ============================================================================

# Copy the pre-generated config header from thirdparty/fizz to the expected location
genrule(
    name = "fizz_config_h",
    srcs = ["@al_proxygen//thirdparty/fizz:fizz-config.h"],
    outs = ["fizz/fizz-config.h"],
    cmd = "cp $< $@",
    visibility = ["//visibility:public"],
)

# ============================================================================
# Source exclusion patterns
# ============================================================================

EXCLUDED_SOURCES = [
    # Test files
    "fizz/**/test/**",
    "fizz/**/*Test.cpp",
    "fizz/**/*Benchmark.cpp",
    # Java crypto extensions (requires JNI)
    "fizz/extensions/javacrypto/**",
    # Tool binaries
    "fizz/tool/**",
    # BogoShim test helper
    "fizz/test/BogoShim.cpp",
    # OQS/liboqs backend (disabled for now - complex to build)
    "fizz/backend/liboqs/**",
    # Brotli compression (requires brotli library which is not configured)
    "fizz/compression/BrotliCertificateCompressor.cpp",
    "fizz/compression/BrotliCertificateDecompressor.cpp",
]

# ============================================================================
# Main fizz library
# ============================================================================

cc_library(
    name = "fizz",
    srcs = glob(
        ["fizz/**/*.cpp"],
        exclude = EXCLUDED_SOURCES,
    ),
    hdrs = glob(
        ["fizz/**/*.h"],
        exclude = [
            "fizz/**/test/**",
            "fizz/**/*-inl.h",
            "fizz/extensions/javacrypto/**",
            "fizz/tool/**",
        ],
    ) + [":fizz_config_h"],
    copts = [
        "-std=c++20",
        "-fcoroutines",
        "-pthread",
        "-Wno-deprecated-declarations",
        "-Wno-sign-compare",
    ] + select({
        "@platforms//cpu:x86_64": ["-maes", "-mpclmul"],
        "//conditions:default": [],
    }),
    defines = [
        "FIZZ_HAVE_SODIUM=1",
        "FIZZ_HAVE_OQS=0",
        "FIZZ_CERTIFICATE_USE_OPENSSL_CERT=1",
    ],
    includes = ["."],
    linkopts = [
        "-pthread",
        "-ldl",
    ],
    textual_hdrs = glob(["fizz/**/*-inl.h"]),
    deps = [
        # Folly - from our thirdparty build
        "@folly_repo//:folly",
        # Boost
        "@boost.variant",
        # Compression
        "@zlib",
        "@zstd",
        # Crypto
        "@openssl//:ssl",
        "@openssl//:crypto",
        "@libsodium",
        # Logging
        "@glog",
        # Formatting
        "@fmt",
    ],
)

# ============================================================================
# Test support libraries
# ============================================================================

cc_library(
    name = "fizz_protocol_cert_util",
    hdrs = ["fizz/protocol/test/CertUtil.h"],
    includes = ["."],
    deps = [":fizz"],
)

cc_library(
    name = "fizz_test_main",
    srcs = ["fizz/test/CMakeTestMain.cpp"],
    deps = [
        "@folly_repo//:folly",
        "@googletest//:gtest",
    ],
)

# Test library sources (excluding actual tests)
# Note: Some test utility files like HmacTest.cpp are NOT tests but test utilities
# They are explicitly included after the exclude
TEST_LIB_SRCS = glob(
    ["fizz/**/test/*.cpp"],
    exclude = [
        "fizz/**/test/*Test.cpp",
        "fizz/test/CMakeTestMain.cpp",
        "fizz/test/BogoShim.cpp",
        "fizz/experimental/ktls/test/AsyncFizzBaseKTLSTest.cpp",
        "fizz/backend/liboqs/test/OQSKeyExchangeTest.cpp",
    ],
) + [
    # Test utility files that have 'Test' in name but are NOT actual tests
    "fizz/crypto/test/HmacTest.cpp",  # Contains runHmacTest() utility function
]

cc_library(
    name = "fizz_test_lib",
    srcs = TEST_LIB_SRCS,
    hdrs = glob(["fizz/**/test/*.h"]),
    copts = [
        "-std=c++20",
        "-fcoroutines",
    ],
    includes = ["."],
    deps = [
        ":fizz",
        "@boost.variant",
        "@folly_repo//:folly",
        "@fmt",
        "@glog",
        "@googletest//:gtest",
        "@openssl//:ssl",
        "@openssl//:crypto",
    ],
)

# ============================================================================
# Tool binary (optional - can be commented out if not needed)
# ============================================================================

cc_library(
    name = "tool_common_lib",
    srcs = ["fizz/tool/FizzCommandCommon.cpp"],
    hdrs = ["fizz/tool/FizzCommandCommon.h"],
    copts = [
        "-std=c++20",
        "-fcoroutines",
    ],
    includes = ["."],
    deps = [
        ":fizz",
        "@folly_repo//:folly",
    ],
)

# ============================================================================
# Unit Tests
# ============================================================================

# Crypto tests
fizz_cc_test(src = "fizz/crypto/test/HkdfTest.cpp")
fizz_cc_test(src = "fizz/crypto/test/HashTest.cpp")
# HmacTest.cpp is a test utility file (contains runHmacTest), not an actual test
fizz_cc_test(src = "fizz/crypto/test/KeyDerivationTest.cpp")
fizz_cc_test(src = "fizz/crypto/test/UtilsTest.cpp")
fizz_cc_test(src = "fizz/crypto/test/RandomGeneratorTest.cpp")

# Crypto exchange tests
fizz_cc_test(src = "fizz/crypto/exchange/test/X25519KeyExchangeTest.cpp")
fizz_cc_test(src = "fizz/crypto/exchange/test/HybridKeyExchangeTest.cpp")

# Crypto AEAD tests
fizz_cc_test(src = "fizz/crypto/aead/test/IOBufUtilTest.cpp")

# HPKE tests
fizz_cc_test(src = "fizz/crypto/hpke/test/HpkeTest.cpp")
fizz_cc_test(src = "fizz/crypto/hpke/test/ContextTest.cpp")
fizz_cc_test(src = "fizz/crypto/hpke/test/DHKEMTest.cpp")

# OpenSSL backend tests
fizz_cc_test(src = "fizz/backend/openssl/certificate/test/CertUtilsTest.cpp")
fizz_cc_test(src = "fizz/backend/openssl/crypto/exchange/test/ECKeyExchangeTest.cpp")
fizz_cc_test(src = "fizz/backend/openssl/crypto/signature/test/ECSignatureTest.cpp")
fizz_cc_test(src = "fizz/backend/openssl/crypto/signature/test/RSAPSSSignatureTest.cpp")
fizz_cc_test(src = "fizz/backend/openssl/crypto/signature/test/EdSignatureTest.cpp")
fizz_cc_test(src = "fizz/backend/openssl/crypto/aead/test/EVPCipherTest.cpp")
fizz_cc_test(src = "fizz/backend/openssl/crypto/test/OpenSSLKeyUtilsTest.cpp")

# Record layer tests
# PlaintextRecordLayerTest.cpp - doesn't exist in current version
# EncryptedRecordLayerTest.cpp - doesn't exist in current version
fizz_cc_test(src = "fizz/record/test/TypesTest.cpp")

# Protocol tests
# ActionsTest.cpp - doesn't exist in current version
# CertificateVerifierTest.cpp - doesn't exist, using DefaultCertificateVerifierTest.cpp instead (below)
fizz_cc_test(src = "fizz/protocol/test/FizzBaseTest.cpp")
fizz_cc_test(src = "fizz/protocol/test/KeySchedulerTest.cpp")

# Client tests
fizz_cc_test(src = "fizz/client/test/ClientProtocolTest.cpp")

# Server tests
fizz_cc_test(src = "fizz/server/test/ServerProtocolTest.cpp")
# TicketTypesTest.cpp - doesn't exist in current version

# Extensions - token binding tests
fizz_cc_test(src = "fizz/extensions/tokenbinding/test/TokenBindingTest.cpp")
fizz_cc_test(src = "fizz/extensions/tokenbinding/test/ValidatorTest.cpp")
fizz_cc_test(src = "fizz/extensions/tokenbinding/test/TokenBindingConstructorTest.cpp")

# Extensions - exported authenticator tests
fizz_cc_test(src = "fizz/extensions/exportedauth/test/ExportedAuthenticatorTest.cpp")

# Extensions - delegated credentials tests
fizz_cc_test(src = "fizz/extensions/delegatedcred/test/DelegatedCredentialUtilsTest.cpp")
fizz_cc_test(src = "fizz/extensions/delegatedcred/test/DelegatedCredTypesTest.cpp")
fizz_cc_test(src = "fizz/extensions/delegatedcred/test/SerializationTest.cpp")
fizz_cc_test(src = "fizz/extensions/delegatedcred/test/DelegatedCredentialCertManagerTest.cpp")
fizz_cc_test(src = "fizz/extensions/delegatedcred/test/DelegatedCredentialClientCertManagerTest.cpp")
fizz_cc_test(src = "fizz/extensions/delegatedcred/test/DelegatedCredentialFactoryTest.cpp")
fizz_cc_test(src = "fizz/extensions/delegatedcred/test/PeerDelegatedCredentialTest.cpp")
fizz_cc_test(src = "fizz/extensions/delegatedcred/test/SelfDelegatedCredentialTest.cpp")

# Extensions - client padding tests
fizz_cc_test(src = "fizz/extensions/clientpadding/test/PaddingClientExtensionTest.cpp")

# Extensions - token binding tests (additional)
fizz_cc_test(src = "fizz/extensions/tokenbinding/test/TokenBindingClientExtensionTest.cpp")
fizz_cc_test(src = "fizz/extensions/tokenbinding/test/TokenBindingServerExtensionTest.cpp")

# Compression tests
fizz_cc_test(src = "fizz/compression/test/ZstdCertificateCompressorTest.cpp")
fizz_cc_test(src = "fizz/compression/test/ZlibCertificateCompressorTest.cpp")
# BrotliCertificateCompressorTest - requires brotli library (not configured)
fizz_cc_test(src = "fizz/compression/test/CertDecompressionManagerTest.cpp")

# Client tests (additional)
fizz_cc_test(src = "fizz/client/test/AsyncFizzClientTest.cpp")
fizz_cc_test(src = "fizz/client/test/CertManagerTest.cpp")
fizz_cc_test(src = "fizz/client/test/FizzClientContextTest.cpp")
fizz_cc_test(src = "fizz/client/test/FizzClientTest.cpp")
fizz_cc_test(src = "fizz/client/test/MultiClientExtensionsTest.cpp")
fizz_cc_test(src = "fizz/client/test/PskSerializationTest.cpp")
fizz_cc_test(src = "fizz/client/test/SynchronizedLruPskCacheTest.cpp")

# Server tests (additional)
fizz_cc_test(src = "fizz/server/test/AeadCookieCipherTest.cpp")
fizz_cc_test(src = "fizz/server/test/AeadTicketCipherTest.cpp")
fizz_cc_test(src = "fizz/server/test/AeadTokenCipherTest.cpp")
fizz_cc_test(src = "fizz/server/test/AsyncFizzServerTest.cpp")
fizz_cc_test(src = "fizz/server/test/CertManagerTest.cpp")
fizz_cc_test(src = "fizz/server/test/CookieCipherTest.cpp")
fizz_cc_test(src = "fizz/server/test/DualTicketCipherTest.cpp")
fizz_cc_test(src = "fizz/server/test/FizzServerTest.cpp")
fizz_cc_test(src = "fizz/server/test/MultiServerExtensionsTest.cpp")
fizz_cc_test(src = "fizz/server/test/NegotiatorTest.cpp")
fizz_cc_test(src = "fizz/server/test/SlidingBloomReplayCacheTest.cpp")
fizz_cc_test(src = "fizz/server/test/TicketCodecTest.cpp")
fizz_cc_test(src = "fizz/server/test/TicketPolicyTest.cpp")

# Record layer tests (additional)
fizz_cc_test(src = "fizz/record/test/BufAndPaddingPolicyTest.cpp")
fizz_cc_test(src = "fizz/record/test/EncryptedRecordTest.cpp")
fizz_cc_test(src = "fizz/record/test/ExtensionsTest.cpp")
fizz_cc_test(src = "fizz/record/test/HandshakeTypesTest.cpp")
fizz_cc_test(src = "fizz/record/test/PlaintextRecordTest.cpp")
fizz_cc_test(src = "fizz/record/test/RecordTest.cpp")

# Protocol tests (additional)
fizz_cc_test(src = "fizz/protocol/test/CertTest.cpp")
fizz_cc_test(src = "fizz/protocol/test/DefaultCertificateVerifierTest.cpp")
fizz_cc_test(src = "fizz/protocol/test/ExporterTest.cpp")
fizz_cc_test(src = "fizz/protocol/test/HandshakeContextTest.cpp")
fizz_cc_test(src = "fizz/protocol/test/MultiBackendFactoryTest.cpp")

# Protocol ECH tests
fizz_cc_test(src = "fizz/protocol/ech/test/DecrypterTest.cpp")
fizz_cc_test(src = "fizz/protocol/ech/test/ECHTest.cpp")
fizz_cc_test(src = "fizz/protocol/ech/test/EncryptionTest.cpp")
fizz_cc_test(src = "fizz/protocol/ech/test/GreaseECHTest.cpp")

# Top-level fizz tests
fizz_cc_test(src = "fizz/test/AsyncFizzBaseTest.cpp")
fizz_cc_test(src = "fizz/test/HandshakeTest.cpp")

# Util tests
fizz_cc_test(src = "fizz/util/test/FizzUtilTest.cpp")
fizz_cc_test(src = "fizz/util/test/FizzVariantTest.cpp")
fizz_cc_test(src = "fizz/util/test/KeyLogWriterTest.cpp")

# Tool tests - excluded, requires fizz/tool/ which is CLI tools not in library
# fizz_cc_test(src = "fizz/tool/test/FizzCommandCommonTest.cpp")

# liboqs backend tests (post-quantum)
fizz_cc_test(src = "fizz/backend/liboqs/test/OQSKeyExchangeTest.cpp")

# Experimental tests
fizz_cc_test(src = "fizz/experimental/batcher/test/BatcherTest.cpp")
fizz_cc_test(src = "fizz/experimental/client/test/BatchSignaturePeerCertTest.cpp")
fizz_cc_test(src = "fizz/experimental/crypto/test/BatchSignatureTest.cpp")
fizz_cc_test(src = "fizz/experimental/crypto/test/MerkleTreeTest.cpp")
fizz_cc_test(src = "fizz/experimental/protocol/test/BatchSignatureTypesTest.cpp")
fizz_cc_test(src = "fizz/experimental/server/test/BatchSignatureAsyncSelfCertTest.cpp")
fizz_cc_test(src = "fizz/experimental/ktls/test/AsyncFizzBaseKTLSTest.cpp")
fizz_cc_test(src = "fizz/experimental/ktls/test/AsyncKTLSRxSocketTest.cpp")
fizz_cc_test(src = "fizz/experimental/ktls/test/AsyncKTLSSocketTest.cpp")
fizz_cc_test(src = "fizz/experimental/ktls/test/KTLSTest.cpp")
fizz_cc_test(src = "fizz/experimental/psp/test/PSPTest.cpp")
fizz_cc_test(src = "fizz/experimental/psp/test/PSPUpgradeTest.cpp")

