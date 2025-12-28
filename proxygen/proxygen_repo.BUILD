# Copyright (c) ArcheLabs
#
# BUILD overlay for the proxygen git_repository.
# This file is used as the build_file for @proxygen_repo.

load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

package(default_visibility = ["//visibility:public"])

# ============================================================================
# proxygen/external - Third-party code bundled with proxygen
# ============================================================================

cc_library(
    name = "http_parser",
    srcs = [
        "proxygen/external/http_parser/http_parser_cpp.cpp",
    ],
    hdrs = [
        "proxygen/external/http_parser/http_parser.h",
    ],
    copts = [
        "-std=c++20",
        "-DHTTP_PARSER_STRICT_URL=1",
        "-Wno-implicit-fallthrough",
    ],
    includes = ["proxygen/external"],
    linkstatic = True,
)

# ============================================================================
# proxygen/lib - Main proxygen library
# ============================================================================

# Code generation rules for HTTPCommonHeaders
genrule(
    name = "gen_http_common_headers",
    srcs = [
        "proxygen/lib/http/HTTPCommonHeaders.txt",
        "proxygen/lib/http/gen_HTTPCommonHeaders.sh",
        "proxygen/lib/utils/gen_perfect_hash_table.sh",
        "proxygen/lib/utils/perfect_hash_table_template.h",
        "proxygen/lib/utils/perfect_hash_table_template.cpp.gperf",
    ],
    outs = [
        "proxygen/lib/http/HTTPCommonHeaders.h",
        "proxygen/lib/http/HTTPCommonHeaders.cpp",
    ],
    cmd = """
set -ex
EXECROOT=$$(pwd)
OUTDIR=$$EXECROOT/$$(dirname $(location proxygen/lib/http/HTTPCommonHeaders.h))
mkdir -p $$OUTDIR
WORKDIR=$$(mktemp -d)
mkdir -p $$WORKDIR/proxygen/lib/http
mkdir -p $$WORKDIR/proxygen/lib/utils
mkdir -p $$WORKDIR/output
cp $(location proxygen/lib/http/HTTPCommonHeaders.txt) $$WORKDIR/proxygen/lib/http/
cp $(location proxygen/lib/http/gen_HTTPCommonHeaders.sh) $$WORKDIR/proxygen/lib/http/
cp $(location proxygen/lib/utils/gen_perfect_hash_table.sh) $$WORKDIR/proxygen/lib/utils/
cp $(location proxygen/lib/utils/perfect_hash_table_template.h) $$WORKDIR/proxygen/lib/utils/
cp $(location proxygen/lib/utils/perfect_hash_table_template.cpp.gperf) $$WORKDIR/proxygen/lib/utils/
chmod +x $$WORKDIR/proxygen/lib/http/gen_HTTPCommonHeaders.sh
chmod +x $$WORKDIR/proxygen/lib/utils/gen_perfect_hash_table.sh
cd $$WORKDIR
./proxygen/lib/http/gen_HTTPCommonHeaders.sh proxygen/lib/http/HTTPCommonHeaders.txt . output gperf
cp $$WORKDIR/output/HTTPCommonHeaders.h $$OUTDIR/HTTPCommonHeaders.h
cp $$WORKDIR/output/HTTPCommonHeaders.cpp $$OUTDIR/HTTPCommonHeaders.cpp
rm -rf $$WORKDIR
    """,
)

# Code generation for TraceEventType and TraceFieldType
genrule(
    name = "gen_trace_event_types",
    srcs = [
        "proxygen/lib/utils/gen_trace_event_constants.py",
        "proxygen/lib/utils/samples/TraceEventType.txt",
        "proxygen/lib/utils/samples/TraceFieldType.txt",
    ],
    outs = [
        "proxygen/lib/utils/TraceEventType.h",
        "proxygen/lib/utils/TraceEventType.cpp",
        "proxygen/lib/utils/TraceFieldType.h",
        "proxygen/lib/utils/TraceFieldType.cpp",
    ],
    cmd = """
        OUTDIR=$$(dirname $(location proxygen/lib/utils/TraceEventType.h))
        python3 $(location proxygen/lib/utils/gen_trace_event_constants.py) \
            --output_type=cpp \
            --input_files=$(location proxygen/lib/utils/samples/TraceEventType.txt),$(location proxygen/lib/utils/samples/TraceFieldType.txt) \
            --output_scope=proxygen \
            --header_path=proxygen/lib/utils \
            --install_dir=$$OUTDIR \
            --fbcode_dir=.
    """,
)

# Code generation for StatsWrapper
genrule(
    name = "gen_stats_wrapper",
    srcs = [
        "proxygen/lib/stats/gen_StatsWrapper.sh",
        "proxygen/lib/stats/BaseStats.h",
    ],
    outs = ["proxygen/lib/stats/StatsWrapper.h"],
    cmd = """
        cat > $(location proxygen/lib/stats/StatsWrapper.h) << 'EOF'
// Auto-generated file. Do not edit.
#pragma once
#include <proxygen/lib/stats/BaseStats.h>
namespace proxygen {
using StatsWrapper = BaseStats;
} // namespace proxygen
EOF
    """,
)

# Main proxygen library - single library with all sources
cc_library(
    name = "proxygen",
    srcs = glob(
        [
            "proxygen/lib/http/*.cpp",
            "proxygen/lib/http/codec/*.cpp",
            "proxygen/lib/http/codec/compress/*.cpp",
            "proxygen/lib/http/codec/webtransport/*.cpp",
            "proxygen/lib/http/connpool/*.cpp",
            "proxygen/lib/http/observer/*.cpp",
            "proxygen/lib/http/session/*.cpp",
            "proxygen/lib/http/structuredheaders/*.cpp",
            "proxygen/lib/http/webtransport/*.cpp",
            "proxygen/lib/sampling/*.cpp",
            "proxygen/lib/services/*.cpp",
            "proxygen/lib/stats/*.cpp",
            "proxygen/lib/transport/*.cpp",
            "proxygen/lib/utils/*.cpp",
        ],
        exclude = [
            "**/*Test*.cpp",
            "**/*Benchmark*.cpp",
            "**/test/**",
            "proxygen/lib/http/codec/compress/experimental/**",
            "proxygen/lib/stats/**",  # Requires fb303 (Facebook-internal)
            "proxygen/lib/transport/**",  # Requires httpserver samples
        ],
    ) + [
        ":gen_http_common_headers",
        ":gen_trace_event_types",
    ],
    hdrs = glob(
        [
            "proxygen/lib/http/*.h",
            "proxygen/lib/http/codec/*.h",
            "proxygen/lib/http/codec/compress/*.h",
            "proxygen/lib/http/codec/webtransport/*.h",
            "proxygen/lib/http/connpool/*.h",
            "proxygen/lib/http/observer/*.h",
            "proxygen/lib/http/session/*.h",
            "proxygen/lib/http/sink/*.h",
            "proxygen/lib/http/structuredheaders/*.h",
            "proxygen/lib/http/webtransport/*.h",
            "proxygen/lib/sampling/*.h",
            "proxygen/lib/services/*.h",
            "proxygen/lib/transport/*.h",
            "proxygen/lib/utils/*.h",
        ],
        exclude = [
            "**/test/**",
            "**/*Test*.h",
            "proxygen/lib/http/codec/compress/experimental/**",
            "proxygen/lib/http/sink/HTTPConnectSink.h",  # Requires Facebook-internal headers
            "proxygen/lib/stats/**",  # Requires fb303 (Facebook-internal)
            "proxygen/lib/transport/**",  # Requires httpserver samples
        ],
    ) + [
        ":gen_http_common_headers",
        ":gen_trace_event_types",
    ],
    copts = [
        "-I.",
        "-Iexternal/proxygen_repo",
        "-I$(GENDIR)/external/proxygen_repo",
        "-I$(GENDIR)/external/proxygen_repo/proxygen/lib",
        "-std=c++20",
    ],
    includes = ["."],
    linkstatic = True,
    deps = [
        ":http_parser",
        "@folly_repo//:folly",
        "@fizz_repo//:fizz",
        "@wangle_repo//:wangle",
        "@mvfst_repo//:mvfst",
        "@glog",
        "@openssl//:ssl",
        "@openssl//:crypto",
        "@zlib",
        "@zstd",
    ],
)

# Alias for backwards compatibility
alias(
    name = "http",
    actual = ":proxygen",
)

alias(
    name = "utils",
    actual = ":proxygen",
)

# ============================================================================
# proxygen/httpserver - HTTP server library
# ============================================================================

cc_library(
    name = "httpserver",
    srcs = [
        "proxygen/httpserver/HTTPServer.cpp",
        "proxygen/httpserver/HTTPServerAcceptor.cpp",
        "proxygen/httpserver/RequestHandlerAdaptor.cpp",
        "proxygen/httpserver/SignalHandler.cpp",
    ],
    hdrs = [
        "proxygen/httpserver/ExMessageHandler.h",
        "proxygen/httpserver/Filters.h",
        "proxygen/httpserver/HTTPServer.h",
        "proxygen/httpserver/HTTPServerAcceptor.h",
        "proxygen/httpserver/HTTPServerOptions.h",
        "proxygen/httpserver/HTTPTransactionHandlerAdaptor.h",
        "proxygen/httpserver/Mocks.h",
        "proxygen/httpserver/PushHandler.h",
        "proxygen/httpserver/RequestHandler.h",
        "proxygen/httpserver/RequestHandlerAdaptor.h",
        "proxygen/httpserver/RequestHandlerFactory.h",
        "proxygen/httpserver/ResponseBuilder.h",
        "proxygen/httpserver/ResponseHandler.h",
        "proxygen/httpserver/ScopedHTTPServer.h",
        "proxygen/httpserver/SignalHandler.h",
    ] + glob(["proxygen/httpserver/filters/*.h"]),
    copts = [
        "-std=c++20",
        "-I.",
        "-Iexternal/proxygen_repo",
        "-I$(GENDIR)/external/proxygen_repo",
        "-I$(GENDIR)/external/proxygen_repo/proxygen/lib",
    ],
    includes = ["."],
    linkstatic = True,
    deps = [
        ":proxygen",
        "@folly_repo//:folly",
        "@wangle_repo//:wangle",
    ],
)

# ============================================================================
# proxygen/httpclient - HTTP client samples
# ============================================================================

cc_library(
    name = "curl_client",
    srcs = [
        "proxygen/httpclient/samples/curl/CurlClient.cpp",
    ],
    hdrs = [
        "proxygen/httpclient/samples/curl/CurlClient.h",
    ],
    copts = [
        "-std=c++20",
        "-I.",
        "-Iexternal/proxygen_repo",
        "-I$(GENDIR)/external/proxygen_repo",
        "-I$(GENDIR)/external/proxygen_repo/proxygen/lib",
    ],
    includes = ["."],
    linkstatic = True,
    deps = [
        ":proxygen",
        "@folly_repo//:folly",
    ],
)

# ============================================================================
# Sample binaries
# ============================================================================

cc_binary(
    name = "proxygen_echo",
    srcs = [
        "proxygen/httpserver/samples/echo/EchoHandler.cpp",
        "proxygen/httpserver/samples/echo/EchoHandler.h",
        "proxygen/httpserver/samples/echo/EchoServer.cpp",
        "proxygen/httpserver/samples/echo/EchoStats.h",
    ],
    copts = [
        "-std=c++20",
        "-I.",
        "-Iexternal/proxygen_repo",
        "-Iexternal/proxygen_repo/proxygen/httpserver/samples/echo",
        "-I$(GENDIR)/external/proxygen_repo",
        "-I$(GENDIR)/external/proxygen_repo/proxygen/lib",
    ],
    deps = [
        ":httpserver",
        ":proxygen",
        "@openssl//:ssl",
        "@openssl//:crypto",
    ],
)

cc_binary(
    name = "proxygen_push",
    srcs = [
        "proxygen/httpserver/samples/push/PushRequestHandler.cpp",
        "proxygen/httpserver/samples/push/PushRequestHandler.h",
        "proxygen/httpserver/samples/push/PushServer.cpp",
        "proxygen/httpserver/samples/push/PushStats.h",
    ],
    copts = [
        "-std=c++20",
        "-I.",
        "-Iexternal/proxygen_repo",
        "-Iexternal/proxygen_repo/proxygen/httpserver/samples/push",
        "-I$(GENDIR)/external/proxygen_repo",
        "-I$(GENDIR)/external/proxygen_repo/proxygen/lib",
    ],
    deps = [
        ":httpserver",
        ":proxygen",
        "@openssl//:ssl",
        "@openssl//:crypto",
    ],
)

cc_binary(
    name = "proxygen_proxy",
    srcs = [
        "proxygen/httpserver/samples/proxy/ProxyHandler.cpp",
        "proxygen/httpserver/samples/proxy/ProxyHandler.h",
        "proxygen/httpserver/samples/proxy/ProxyServer.cpp",
        "proxygen/httpserver/samples/proxy/ProxyStats.h",
        "proxygen/httpserver/samples/proxy/SessionWrapper.h",
    ],
    copts = [
        "-std=c++20",
        "-I.",
        "-Iexternal/proxygen_repo",
        "-Iexternal/proxygen_repo/proxygen/httpserver/samples/proxy",
        "-I$(GENDIR)/external/proxygen_repo",
        "-I$(GENDIR)/external/proxygen_repo/proxygen/lib",
    ],
    deps = [
        ":httpserver",
        ":proxygen",
        "@openssl//:ssl",
        "@openssl//:crypto",
    ],
)

cc_binary(
    name = "proxygen_static",
    srcs = [
        "proxygen/httpserver/samples/static/StaticHandler.cpp",
        "proxygen/httpserver/samples/static/StaticHandler.h",
        "proxygen/httpserver/samples/static/StaticServer.cpp",
    ],
    copts = [
        "-std=c++20",
        "-I.",
        "-Iexternal/proxygen_repo",
        "-I$(GENDIR)/external/proxygen_repo",
        "-I$(GENDIR)/external/proxygen_repo/proxygen/lib",
    ],
    deps = [
        ":httpserver",
        ":proxygen",
        "@openssl//:ssl",
        "@openssl//:crypto",
    ],
)
