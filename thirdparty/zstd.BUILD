# Build file for zstd - uses system library
load("@rules_cc//cc:defs.bzl", "cc_library")
package(default_visibility = ["//visibility:public"])
cc_library(
    name = "zstd",
    hdrs = glob(["**/*.h", "**/*.hpp"], allow_empty = True),
    linkopts = ["-lzstd"],
    visibility = ["//visibility:public"],
)
