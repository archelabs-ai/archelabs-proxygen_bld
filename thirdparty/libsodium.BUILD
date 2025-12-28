# Build file for libsodium - uses system library
load("@rules_cc//cc:defs.bzl", "cc_library")
package(default_visibility = ["//visibility:public"])
cc_library(
    name = "libsodium",
    hdrs = glob(["**/*.h", "**/*.hpp"], allow_empty = True),
    linkopts = ["-llibsodium"],
    visibility = ["//visibility:public"],
)
