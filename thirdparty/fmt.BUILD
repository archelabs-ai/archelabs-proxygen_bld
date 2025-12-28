# Build file for fmtlib/fmt - https://github.com/fmtlib/fmt
load("@rules_cc//cc:defs.bzl", "cc_library")
package(default_visibility = ["//visibility:public"])

cc_library(
    name = "fmt",
    hdrs = glob(["include/**/*.h"]),
    srcs = glob(["src/*.cc"], exclude = ["src/fmt.cc"]),
    includes = ["include"],
    copts = [
        "-std=c++20",
        "-DFMT_HEADER_ONLY=0",
    ],
    visibility = ["//visibility:public"],
)
