# cpp_library.bzl - Wrapper macro for cc_library that adds include_hack for angle bracket includes
# Following the BCR folly pattern from https://github.com/nicholasjng/bazel-central-registry/tree/folly/modules/folly/2025.01.13.00.bcr.3/overlay/bzl

load("@rules_cc//cc:defs.bzl", "cc_library")

def cpp_library(
        name,
        srcs = [],
        hdrs = [],
        deps = [],
        copts = [],
        linkopts = [],
        defines = [],
        includes = [],
        textual_hdrs = [],
        visibility = None,
        **kwargs):
    """
    A wrapper around cc_library that adds the include_hack target to deps.

    This allows headers to be included with angle brackets like:
        #include <folly/Foo.h>

    Instead of quoted includes:
        #include "folly/Foo.h"
    """

    # Add include_hack to deps for angle bracket include support
    augmented_deps = deps + ["//:include_hack"]

    cc_library(
        name = name,
        srcs = srcs,
        hdrs = hdrs,
        deps = augmented_deps,
        copts = copts,
        linkopts = linkopts,
        defines = defines,
        includes = includes,
        textual_hdrs = textual_hdrs,
        visibility = visibility,
        **kwargs
    )

def cpp_test(
        name,
        srcs = [],
        deps = [],
        copts = [],
        linkopts = [],
        data = [],
        **kwargs):
    """
    A wrapper around cc_test that adds the include_hack target to deps.
    """
    native.cc_test(
        name = name,
        srcs = srcs,
        deps = deps + ["//:include_hack"],
        copts = copts,
        linkopts = linkopts,
        data = data,
        **kwargs
    )
