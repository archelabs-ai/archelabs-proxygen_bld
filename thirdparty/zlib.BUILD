# Build file for zlib - uses system library
load("@rules_cc//cc:defs.bzl", "cc_library")
package(default_visibility = ["//visibility:public"])
cc_library(
    name = "zlib",
    hdrs = glob(["**/*.h", "**/*.hpp"], allow_empty = True),
    linkopts = ["-lzlib"],
    visibility = ["//visibility:public"],
)
