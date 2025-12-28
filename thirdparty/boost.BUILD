# Build file for boost - uses system library
load("@rules_cc//cc:defs.bzl", "cc_library")
package(default_visibility = ["//visibility:public"])
cc_library(
    name = "boost",
    hdrs = glob(["**/*.h", "**/*.hpp"], allow_empty = True),
    linkopts = ["-lboost"],
    visibility = ["//visibility:public"],
)
