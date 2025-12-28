# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the Apache License, Version 2.0.
# See the LICENSE file in the root directory of this source tree.

"""
BUILD.bazel overlay for the wangle git repository.

This file is applied on top of the wangle repo via build_file attribute
in git_repository. Wangle is Facebook's C++ networking library.

Wangle provides a full-featured, high-performance C++ networking library
with a focus on building client/server abstractions.
"""

load("@rules_cc//cc:defs.bzl", "cc_library", "cc_test")
load("@//thirdparty/wangle:defs.bzl", "wangle_cc_test", "WANGLE_TEST_COPTS")

package(default_visibility = ["//visibility:public"])

# Export license
exports_files(["LICENSE"])

# Common copts for all wangle targets
WANGLE_COPTS = [
    "-std=c++20",
    "-fcoroutines",
    "-pthread",
    "-Wno-deprecated-declarations",
    "-Wno-sign-compare",
]

# ============================================================================
# Utility library (no deps on other wangle components)
# ============================================================================

cc_library(
    name = "util",
    srcs = glob(["wangle/util/*.cpp"]),
    hdrs = glob(["wangle/util/*.h"]),
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        "@folly_repo//:folly",
        "@glog",
    ],
)

# ============================================================================
# SSL library
# ============================================================================

cc_library(
    name = "ssl",
    srcs = glob(["wangle/ssl/*.cpp"]),
    # Include SSLContextSelectionMisc.h from acceptor to avoid circular deps
    hdrs = glob(["wangle/ssl/*.h"]) + ["wangle/acceptor/SSLContextSelectionMisc.h"],
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        ":util",
        "@folly_repo//:folly",
        "@fmt",
        "@glog",
        "@openssl//:ssl",
        "@openssl//:crypto",
    ],
)

# ============================================================================
# Acceptor library
# ============================================================================

cc_library(
    name = "acceptor",
    srcs = glob(
        ["wangle/acceptor/*.cpp"],
        exclude = ["wangle/acceptor/test/**"],
    ),
    hdrs = glob(
        ["wangle/acceptor/*.h"],
        exclude = ["wangle/acceptor/test/**"],
    ),
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        ":ssl",
        "@fizz_repo//:fizz",
        "@folly_repo//:folly",
        "@fmt",
        "@glog",
        "@openssl//:ssl",
        "@openssl//:crypto",
    ],
)

# ============================================================================
# Channel library
# ============================================================================

cc_library(
    name = "channel",
    srcs = glob(
        ["wangle/channel/*.cpp"],
        exclude = ["wangle/channel/test/**"],
    ),
    hdrs = glob(
        ["wangle/channel/*.h"],
        exclude = [
            "wangle/channel/*-inl.h",
            "wangle/channel/test/**",
        ],
    ),
    copts = WANGLE_COPTS,
    includes = ["."],
    textual_hdrs = glob(["wangle/channel/*-inl.h"]),
    deps = [
        ":acceptor",
        "@folly_repo//:folly",
        "@glog",
    ],
)

# ============================================================================
# Channel broadcast library
# ============================================================================

cc_library(
    name = "channel_broadcast",
    hdrs = glob(
        ["wangle/channel/broadcast/*.h"],
        exclude = ["wangle/channel/broadcast/*-inl.h"],
    ),
    copts = WANGLE_COPTS,
    includes = ["."],
    textual_hdrs = glob(["wangle/channel/broadcast/*-inl.h"]),
    deps = [
        ":bootstrap",
        ":channel",
        "@folly_repo//:folly",
    ],
)

# ============================================================================
# Bootstrap library
# ============================================================================

cc_library(
    name = "bootstrap",
    srcs = glob(
        ["wangle/bootstrap/*.cpp"],
        exclude = ["wangle/bootstrap/test/**"],
    ),
    hdrs = glob(
        ["wangle/bootstrap/*.h"],
        exclude = [
            "wangle/bootstrap/*-inl.h",
            "wangle/bootstrap/test/**",
        ],
    ),
    copts = WANGLE_COPTS,
    includes = ["."],
    textual_hdrs = glob(["wangle/bootstrap/*-inl.h"]),
    deps = [
        ":acceptor",
        ":channel",
        ":ssl",
        "@folly_repo//:folly",
        "@glog",
    ],
)

# ============================================================================
# Client persistence library
# ============================================================================

cc_library(
    name = "client_persistence",
    srcs = glob(
        ["wangle/client/persistence/*.cpp"],
        exclude = ["wangle/client/persistence/test/**"],
    ),
    hdrs = glob(
        ["wangle/client/persistence/*.h"],
        exclude = [
            "wangle/client/persistence/*-inl.h",
            "wangle/client/persistence/test/**",
        ],
    ),
    copts = WANGLE_COPTS,
    includes = ["."],
    textual_hdrs = glob(["wangle/client/persistence/*-inl.h"]),
    deps = [
        "@folly_repo//:folly",
    ],
)

cc_library(
    name = "client_persistence_test_lib",
    srcs = ["wangle/client/persistence/test/TestUtil.cpp"],
    hdrs = [
        "wangle/client/persistence/test/Mocks.h",
        "wangle/client/persistence/test/TestUtil.h",
    ],
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        ":client_persistence",
        "@folly_repo//:folly",
        "@googletest//:gtest",
    ],
)

# ============================================================================
# Client SSL library
# ============================================================================

cc_library(
    name = "client_ssl",
    srcs = glob(
        ["wangle/client/ssl/*.cpp"],
        exclude = ["wangle/client/ssl/test/**"],
    ),
    hdrs = glob(
        ["wangle/client/ssl/*.h"],
        exclude = [
            "wangle/client/ssl/*-inl.h",
            "wangle/client/ssl/test/**",
        ],
    ),
    copts = WANGLE_COPTS,
    includes = ["."],
    textual_hdrs = glob(["wangle/client/ssl/*-inl.h"]),
    deps = [
        ":client_persistence",
        ":ssl",
        "@folly_repo//:folly",
        "@openssl//:ssl",
        "@openssl//:crypto",
    ],
)

cc_library(
    name = "client_ssl_test_lib",
    srcs = ["wangle/client/ssl/test/TestUtil.cpp"],
    hdrs = [
        "wangle/client/ssl/test/Mocks.h",
        "wangle/client/ssl/test/TestUtil.h",
    ],
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        ":client_ssl",
        "@folly_repo//:folly",
        "@googletest//:gtest",
    ],
)

# ============================================================================
# Codec library
# ============================================================================

cc_library(
    name = "codec",
    srcs = glob(
        ["wangle/codec/*.cpp"],
        exclude = ["wangle/codec/test/**"],
    ),
    hdrs = glob(
        ["wangle/codec/*.h"],
        exclude = ["wangle/codec/test/**"],
    ),
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        ":channel",
        "@folly_repo//:folly",
    ],
)

cc_library(
    name = "codec_test_lib",
    hdrs = ["wangle/codec/test/CodecTestUtils.h"],
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        ":codec",
        "@folly_repo//:folly",
        "@googletest//:gtest",
    ],
)

# ============================================================================
# Service library
# ============================================================================

cc_library(
    name = "service",
    hdrs = glob(["wangle/service/*.h"]),
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        ":bootstrap",
        ":channel",
        "@folly_repo//:folly",
    ],
)

# ============================================================================
# Combined wangle library (all components)
# ============================================================================

cc_library(
    name = "wangle",
    deps = [
        ":acceptor",
        ":bootstrap",
        ":channel",
        ":channel_broadcast",
        ":client_persistence",
        ":client_ssl",
        ":codec",
        ":service",
        ":ssl",
        ":util",
    ],
)

# ============================================================================
# Test support libraries
# ============================================================================

cc_library(
    name = "test_main",
    srcs = ["wangle/test/TestMain.cpp"],
    copts = WANGLE_COPTS,
    deps = [
        "@folly_repo//:folly",
        "@googletest//:gtest",
    ],
)

cc_library(
    name = "acceptor_test_lib",
    hdrs = ["wangle/acceptor/test/AcceptorHelperMocks.h"],
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        ":acceptor",
        "@folly_repo//:folly_test_util",
        "@googletest//:gtest",
    ],
)

cc_library(
    name = "bootstrap_test_lib",
    hdrs = ["wangle/bootstrap/test/Mocks.h"],
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        ":bootstrap",
        ":channel",
        ":channel_test_lib",
        "@googletest//:gtest",
    ],
)

cc_library(
    name = "channel_test_lib",
    hdrs = [
        "wangle/channel/test/MockHandler.h",
        "wangle/channel/test/MockPipeline.h",
        "wangle/channel/broadcast/test/Mocks.h",
    ],
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        ":channel",
        ":codec",
        "@folly_repo//:folly",
        "@googletest//:gtest",
    ],
)

cc_library(
    name = "ssl_test_lib",
    hdrs = [
        "wangle/ssl/test/MockSSLStats.h",
        "wangle/ssl/test/TicketUtil.h",
    ],
    copts = WANGLE_COPTS,
    includes = ["."],
    deps = [
        ":ssl",
        "@folly_repo//:folly",
        "@folly_repo//:folly_test_util",
        "@googletest//:gtest",
    ],
)

# ============================================================================
# Unit Tests
# ============================================================================

# Acceptor tests
wangle_cc_test(
    src = "wangle/acceptor/test/AcceptorTest.cpp",
    deps = [":acceptor", ":acceptor_test_lib"],
)
wangle_cc_test(
    src = "wangle/acceptor/test/ConnectionManagerTest.cpp",
    deps = [":acceptor", ":acceptor_test_lib"],
)
wangle_cc_test(
    src = "wangle/acceptor/test/LoadShedConfigurationTest.cpp",
    deps = [":acceptor"],
)
wangle_cc_test(
    src = "wangle/acceptor/test/EvbHandshakeHelperTest.cpp",
    deps = [":acceptor", ":acceptor_test_lib"],
)
wangle_cc_test(
    src = "wangle/acceptor/test/PeekingAcceptorHandshakeHelperTest.cpp",
    deps = [":acceptor", ":acceptor_test_lib"],
)
wangle_cc_test(
    src = "wangle/acceptor/test/SecurityProtocolContextManagerTest.cpp",
    deps = [":acceptor", ":acceptor_test_lib"],
)
wangle_cc_test(
    src = "wangle/acceptor/test/SharedSSLContextManagerTest.cpp",
    deps = [":acceptor", ":acceptor_test_lib", ":ssl"],
)
wangle_cc_test(
    src = "wangle/acceptor/test/SocketPeekerTest.cpp",
    deps = [":acceptor", ":acceptor_test_lib"],
)

# Channel tests
wangle_cc_test(
    src = "wangle/channel/test/PipelineTest.cpp",
    deps = [":channel", ":channel_test_lib"],
)
wangle_cc_test(
    src = "wangle/channel/test/OutputBufferingHandlerTest.cpp",
    deps = [":channel", ":channel_test_lib"],
)
wangle_cc_test(
    src = "wangle/channel/test/AsyncSocketHandlerTest.cpp",
    deps = [":channel", ":channel_test_lib"],
)
wangle_cc_test(
    src = "wangle/channel/test/FileRegionTest.cpp",
    deps = [":channel", ":channel_test_lib"],
)

# Channel broadcast tests
wangle_cc_test(
    src = "wangle/channel/broadcast/test/BroadcastHandlerTest.cpp",
    deps = [":channel_broadcast", ":channel_test_lib"],
)
wangle_cc_test(
    src = "wangle/channel/broadcast/test/BroadcastPoolTest.cpp",
    deps = [":channel_broadcast", ":channel_test_lib", ":bootstrap"],
)
wangle_cc_test(
    src = "wangle/channel/broadcast/test/ObservingClientPipelineTest.cpp",
    deps = [":channel_broadcast", ":channel_test_lib"],
)
wangle_cc_test(
    src = "wangle/channel/broadcast/test/ObservingHandlerTest.cpp",
    deps = [":channel_broadcast", ":channel_test_lib"],
)

# Bootstrap tests
wangle_cc_test(
    src = "wangle/bootstrap/test/BootstrapTest.cpp",
    deps = [":bootstrap", ":bootstrap_test_lib", ":channel"],
)
wangle_cc_test(
    src = "wangle/bootstrap/test/AcceptRoutingHandlerTest.cpp",
    deps = [":bootstrap", ":bootstrap_test_lib", ":channel"],
)

# Codec tests
wangle_cc_test(
    src = "wangle/codec/test/CodecTest.cpp",
    deps = [":codec", ":codec_test_lib"],
)

# Service tests
wangle_cc_test(
    src = "wangle/service/test/ServiceTest.cpp",
    deps = [":service", ":channel", ":codec"],
)

# SSL tests
wangle_cc_test(
    src = "wangle/ssl/test/SSLContextManagerTest.cpp",
    deps = [":ssl", ":ssl_test_lib"],
)
wangle_cc_test(
    src = "wangle/ssl/test/TLSCredProcessorTest.cpp",
    deps = [":ssl", ":ssl_test_lib"],
)
wangle_cc_test(
    src = "wangle/ssl/test/TLSTicketKeyManagerTest.cpp",
    deps = [":ssl", ":ssl_test_lib"],
)
wangle_cc_test(
    src = "wangle/ssl/test/SSLCacheTest.cpp",
    deps = [":ssl", ":ssl_test_lib"],
)
wangle_cc_test(
    src = "wangle/ssl/test/SSLSessionCacheManagerTest.cpp",
    deps = [":ssl", ":ssl_test_lib"],
)
wangle_cc_test(
    src = "wangle/ssl/test/TLSInMemoryTicketProcessorTest.cpp",
    deps = [":ssl", ":ssl_test_lib"],
)

# Client persistence tests
wangle_cc_test(
    src = "wangle/client/persistence/test/LRUPersistentCacheTest.cpp",
    deps = [":client_persistence", ":client_persistence_test_lib"],
)
wangle_cc_test(
    src = "wangle/client/persistence/test/FilePersistentCacheTest.cpp",
    deps = [":client_persistence", ":client_persistence_test_lib"],
)
wangle_cc_test(
    src = "wangle/client/persistence/test/PersistentCacheCommonTest.cpp",
    deps = [":client_persistence", ":client_persistence_test_lib"],
)

# Client SSL tests
wangle_cc_test(
    src = "wangle/client/ssl/test/SSLSessionCallbackTest.cpp",
    deps = [":client_ssl", ":client_ssl_test_lib"],
)
wangle_cc_test(
    src = "wangle/client/ssl/test/SSLSessionCacheDataTest.cpp",
    deps = [":client_ssl", ":client_ssl_test_lib"],
)
wangle_cc_test(
    src = "wangle/client/ssl/test/SSLSessionPersistentCacheTest.cpp",
    deps = [":client_ssl", ":client_ssl_test_lib", ":client_persistence", ":client_persistence_test_lib"],
)
wangle_cc_test(
    src = "wangle/client/ssl/test/ThreadSafeSSLSessionCacheTest.cpp",
    deps = [":client_ssl", ":client_ssl_test_lib"],
)

# Util tests
wangle_cc_test(
    src = "wangle/util/test/FilePollerTest.cpp",
    deps = [":util"],
)
wangle_cc_test(
    src = "wangle/util/test/MultiFilePollerTest.cpp",
    deps = [":util"],
)

