# Build file for c-ares - uses system library
load("@rules_cc//cc:defs.bzl", "cc_library")
package(default_visibility = ["//visibility:public"])
cc_library(
    name = "c-ares",
    hdrs = glob(["**/*.h", "**/*.hpp"], allow_empty = True),
    linkopts = ["-lc-ares"],
    visibility = ["//visibility:public"],
)
