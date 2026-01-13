# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

"""
BUILD.bazel overlay for the mvfst git repository.

This file is applied on top of the mvfst repo via build_file attribute
in git_repository. mvfst is Facebook's implementation of the QUIC protocol.

NOTE: This is built as one monolithic library because the headers have
complex circular dependencies between components.
"""

load("@rules_cc//cc:defs.bzl", "cc_library", "cc_test")
load("@al_proxygen//thirdparty/mvfst:defs.bzl", "mvfst_cc_test", "MVFST_TEST_COPTS")

package(default_visibility = ["//visibility:public"])

# Export license
exports_files(["LICENSE"])

# Common copts for all mvfst targets
MVFST_COPTS = [
    "-std=c++20",
    "-fcoroutines",
    "-pthread",
    "-Wno-deprecated-declarations",
    "-Wno-sign-compare",
]

# ============================================================================
# Source exclusion patterns
# ============================================================================

# Common exclusions for all mvfst builds
COMMON_EXCLUDED_SOURCES = [
    # Mobile-specific files (conflict with non-mobile versions, incomplete types)
    "quic/api/QuicBatchWriterFactoryMobile.cpp",
    "quic/congestion_control/PacerFactoryMobile.cpp",
    "quic/congestion_control/CongestionControllerFactoryMobile.cpp",
    # Samples and tools
    "quic/samples/**",
    "quic/tools/**",
    # Tests
    "quic/**/test/**",
    "quic/**/testutil/**",
]

# Default build: use standard backend, exclude io_uring backend
EXCLUDED_SOURCES = COMMON_EXCLUDED_SOURCES + [
    "quic/server/QuicServerBackendIoUring.cpp",
]

# io_uring build: use io_uring backend, exclude standard backend
EXCLUDED_SOURCES_URING = COMMON_EXCLUDED_SOURCES + [
    "quic/server/QuicServerBackend.cpp",
]

EXCLUDED_HEADERS = [
    # Test utilities
    "quic/common/testutil/**",
    "quic/**/test/**",
    # Samples and tools
    "quic/samples/**",
    "quic/tools/**",
    # Inline headers (textual_hdrs)
    "quic/**/*-inl.h",
]

# ============================================================================
# Main QUIC library (default backend, no io_uring)
# ============================================================================

cc_library(
    name = "quic",
    srcs = glob(
        ["quic/**/*.cpp"],
        exclude = EXCLUDED_SOURCES,
    ),
    hdrs = glob(
        [
            "quic/**/*.h",
            "quic/**/*.hpp",  # Include third-party headers
        ],
        exclude = EXCLUDED_HEADERS,
    ),
    copts = MVFST_COPTS,
    includes = ["."],
    linkopts = [
        "-pthread",
        "-ldl",
    ],
    textual_hdrs = glob(
        ["quic/**/*-inl.h"],
        exclude = ["quic/**/test/**"],
    ),
    deps = [
        # Facebook libraries
        "@fizz_repo//:fizz",
        "@folly_repo//:folly",
        "@wangle_repo//:wangle",
        # Boost
        "@boost.iterator",
        # Other deps
        "@fmt",
        "@glog",
        "@libev_repo//:libev",
        "@libsodium",
        "@openssl//:ssl",
        "@openssl//:crypto",
        "@zlib",
    ],
)

# ============================================================================
# QUIC library with io_uring backend (high-performance Linux)
# ============================================================================

cc_library(
    name = "quic_uring",
    srcs = glob(
        ["quic/**/*.cpp"],
        exclude = EXCLUDED_SOURCES_URING,
    ),
    hdrs = glob(
        [
            "quic/**/*.h",
            "quic/**/*.hpp",
        ],
        exclude = EXCLUDED_HEADERS,
    ),
    copts = MVFST_COPTS,
    includes = ["."],
    linkopts = [
        "-pthread",
        "-ldl",
    ],
    textual_hdrs = glob(
        ["quic/**/*-inl.h"],
        exclude = ["quic/**/test/**"],
    ),
    deps = [
        # Facebook libraries
        "@fizz_repo//:fizz",
        "@folly_repo//:folly",
        "@wangle_repo//:wangle",
        # Boost
        "@boost.iterator",
        # Other deps
        "@fmt",
        "@glog",
        "@libev_repo//:libev",
        "@libsodium",
        "@liburing_repo//:liburing",  # io_uring support
        "@openssl//:ssl",
        "@openssl//:crypto",
        "@zlib",
    ],
)

# ============================================================================
# Test support libraries
# ============================================================================

cc_library(
    name = "quic_test_lib",
    srcs = glob(
        [
            "quic/**/test/*.cpp",
        ],
        allow_empty = True,
        exclude = [
            "quic/common/test/TestMain.cpp",
            "quic/**/test/*Test.cpp",
            "quic/**/test/*Benchmark.cpp",
        ],
    ),
    hdrs = glob(
        [
            "quic/**/test/*.h",
            "quic/common/testutil/*.h",
        ],
        allow_empty = True,
    ),
    copts = MVFST_COPTS,
    includes = ["."],
    deps = [
        ":quic",
        "@fizz_repo//:fizz",
        "@fizz_repo//:fizz_test_lib",
        "@folly_repo//:folly",
        "@glog",
        "@googletest//:gtest",
        "@libsodium",
    ],
)

cc_library(
    name = "quic_test_main",
    srcs = ["quic/common/test/TestMain.cpp"],
    copts = MVFST_COPTS,
    deps = [
        "@folly_repo//:folly",
        "@googletest//:gtest",
    ],
)

# ============================================================================
# Unit tests
# ============================================================================

# Codec tests
mvfst_cc_test(src = "quic/codec/test/QuicConnectionIdTest.cpp")
mvfst_cc_test(src = "quic/codec/test/QuicPacketBuilderTest.cpp")
mvfst_cc_test(src = "quic/codec/test/QuicReadCodecTest.cpp")
mvfst_cc_test(src = "quic/codec/test/TypesTest.cpp")
mvfst_cc_test(src = "quic/codec/test/DecodeTest.cpp")
mvfst_cc_test(src = "quic/codec/test/DefaultConnectionIdAlgoTest.cpp")
mvfst_cc_test(src = "quic/codec/test/PacketNumberTest.cpp")
mvfst_cc_test(src = "quic/codec/test/QuicHeaderCodecTest.cpp")
mvfst_cc_test(src = "quic/codec/test/QuicIntegerTest.cpp")
mvfst_cc_test(src = "quic/codec/test/QuicPacketRebuilderTest.cpp")
mvfst_cc_test(src = "quic/codec/test/QuicWriteCodecTest.cpp")
mvfst_cc_test(src = "quic/codec/test/ServerConnectionIdParamsTest.cpp")

# Common tests
mvfst_cc_test(src = "quic/common/test/CircularDequeTest.cpp")
mvfst_cc_test(src = "quic/common/test/IntervalSetTest.cpp")
mvfst_cc_test(src = "quic/common/test/VariantTest.cpp")
mvfst_cc_test(src = "quic/common/test/BufAccessorTest.cpp")
mvfst_cc_test(src = "quic/common/test/BufUtilTest.cpp")
mvfst_cc_test(src = "quic/common/test/ChainedByteRangeTest.cpp")
mvfst_cc_test(src = "quic/common/test/ContiguousCursorTest.cpp")
mvfst_cc_test(src = "quic/common/test/FunctionLooperTest.cpp")
mvfst_cc_test(src = "quic/common/test/QuicBufferTest.cpp")
mvfst_cc_test(src = "quic/common/test/QuicRangeConversionTest.cpp")
mvfst_cc_test(src = "quic/common/test/SocketUtilTest.cpp")
mvfst_cc_test(src = "quic/common/test/StringUtilsTest.cpp")
mvfst_cc_test(src = "quic/common/test/TimeUtilTest.cpp")
mvfst_cc_test(src = "quic/common/test/TransportKnobsTest.cpp")
mvfst_cc_test(src = "quic/common/events/test/FollyQuicEventBaseTest.cpp")
mvfst_cc_test(src = "quic/common/udpsocket/test/FollyQuicAsyncUDPSocketTest.cpp")

# Congestion control tests
mvfst_cc_test(src = "quic/congestion_control/test/CubicTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/BbrTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/NewRenoTest.cpp")
# Copa2Test has AckEvent constructor mismatch
mvfst_cc_test(src = "quic/congestion_control/test/BandwidthTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/Bbr2Test.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/BbrBandwidthSamplerTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/BbrRttSamplerTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/CongestionControlFunctionsTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/CopaTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/CubicHystartTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/CubicRecoveryTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/CubicStateTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/CubicSteadyTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/EcnL4sTrackerTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/PacerTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/SimulatedTBFTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/StaticCwndCongestionControllerTest.cpp")
mvfst_cc_test(src = "quic/congestion_control/test/ThrottlingSignalProviderTest.cpp")

# Flow control tests
mvfst_cc_test(src = "quic/flowcontrol/test/QuicFlowControlTest.cpp")

# Handshake tests
mvfst_cc_test(src = "quic/handshake/test/TransportParametersTest.cpp")

# Loss detection tests
mvfst_cc_test(src = "quic/loss/test/QuicLossFunctionsTest.cpp")

# Logging tests
mvfst_cc_test(src = "quic/logging/test/QLoggerTest.cpp")

# Priority tests
mvfst_cc_test(src = "quic/priority/test/PriorityQueueTest.cpp")
mvfst_cc_test(src = "quic/priority/test/HTTPPriorityQueueTest.cpp")

# Observer tests
mvfst_cc_test(src = "quic/observer/test/SocketObserverInterfaceTest.cpp")

# State tests
mvfst_cc_test(src = "quic/state/test/QuicStateFunctionsTest.cpp")
mvfst_cc_test(src = "quic/state/test/QuicStreamFunctionsTest.cpp")
mvfst_cc_test(src = "quic/state/test/AckHandlersTest.cpp")
mvfst_cc_test(src = "quic/state/test/QuicStreamManagerTest.cpp")
mvfst_cc_test(src = "quic/state/stream/test/StreamStateFunctionsTest.cpp")
mvfst_cc_test(src = "quic/state/stream/test/StreamStateMachineTest.cpp")
mvfst_cc_test(src = "quic/state/test/AckedPacketIteratorTest.cpp")
mvfst_cc_test(src = "quic/state/test/ClonedPacketIdentifierTest.cpp")
mvfst_cc_test(src = "quic/state/test/OutstandingPacketTest.cpp")
mvfst_cc_test(src = "quic/state/test/QuicPacingFunctionsTest.cpp")
mvfst_cc_test(src = "quic/state/test/QuicPathManagerTest.cpp")
mvfst_cc_test(src = "quic/state/test/StateDataTest.cpp")
mvfst_cc_test(src = "quic/state/test/StreamDataTest.cpp")
mvfst_cc_test(src = "quic/state/test/TransportSettingsFunctionsTest.cpp")

# Fizz handshake tests
mvfst_cc_test(
    src = "quic/fizz/handshake/test/FizzTransportParametersTest.cpp",
    deps = ["@fizz_repo//:fizz"],
)
mvfst_cc_test(
    src = "quic/fizz/handshake/test/FizzCryptoFactoryTest.cpp",
    deps = ["@fizz_repo//:fizz"],
)
mvfst_cc_test(
    src = "quic/fizz/handshake/test/FizzPacketNumberCipherTest.cpp",
    deps = ["@fizz_repo//:fizz"],
)
mvfst_cc_test(
    src = "quic/fizz/client/handshake/test/FizzClientExtensionsTest.cpp",
    deps = ["@fizz_repo//:fizz"],
)
mvfst_cc_test(
    src = "quic/fizz/client/handshake/test/FizzClientHandshakeTest.cpp",
    deps = ["@fizz_repo//:fizz"],
)

# API tests
mvfst_cc_test(src = "quic/api/test/QuicBatchWriterTest.cpp")
mvfst_cc_test(src = "quic/api/test/QuicPacketSchedulerTest.cpp")
mvfst_cc_test(src = "quic/api/test/QuicTransportFunctionsTest.cpp")
mvfst_cc_test(src = "quic/api/test/IoBufQuicBatchTest.cpp")
mvfst_cc_test(src = "quic/api/test/QuicSocketTest.cpp")
mvfst_cc_test(src = "quic/api/test/QuicStreamAsyncTransportTest.cpp")
mvfst_cc_test(src = "quic/api/test/QuicTransportBaseTest.cpp")
mvfst_cc_test(src = "quic/api/test/QuicTransportTest.cpp")
mvfst_cc_test(src = "quic/api/test/QuicTypedTransportTest.cpp")

# Client tests
mvfst_cc_test(src = "quic/client/test/ClientStateMachineTest.cpp")
mvfst_cc_test(src = "quic/client/test/QuicConnectorTest.cpp")

# Server tests
mvfst_cc_test(src = "quic/server/test/QuicServerTest.cpp")
mvfst_cc_test(src = "quic/server/test/ServerStateMachineTest.cpp")
mvfst_cc_test(src = "quic/server/test/SlidingWindowRateLimiterTest.cpp")

# Server handshake tests
mvfst_cc_test(src = "quic/server/handshake/test/AppTokenTest.cpp")
mvfst_cc_test(src = "quic/server/handshake/test/DefaultAppTokenValidatorTest.cpp")
mvfst_cc_test(src = "quic/server/handshake/test/RetryTokenGeneratorTest.cpp")
mvfst_cc_test(src = "quic/server/handshake/test/ServerHandshakeTest.cpp")
mvfst_cc_test(src = "quic/server/handshake/test/ServerTransportParametersTest.cpp")
mvfst_cc_test(src = "quic/server/handshake/test/StatelessResetGeneratorTest.cpp")

# Tool tests - excluded (tperf is a tool, not a library)
# mvfst_cc_test(src = "quic/tools/tperf/test/PacingObserverTest.cpp")


# Alias for convenience
alias(
    name = "mvfst",
    actual = ":quic",
)

