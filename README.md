# Bazel Build for Proxygen

Bazel build system for [Proxygen](https://github.com/facebook/proxygen) and its dependencies. Fetches sources from official Facebook repositories (currently v2025.12.15.00).

## Prerequisites

- Bazel 8.x
- Linux (tested on Ubuntu/Debian)
- C++20 compiler with coroutine support
- OpenSSL, zlib, libunwind (system packages)

```bash
# Ubuntu/Debian
sudo apt install libssl-dev zlib1g-dev libunwind-dev libdwarf-dev libaio-dev
```

## Build

```bash
# Build all libraries
bazel build //...

# Build specific targets
bazel build //:proxygen
bazel build //:folly
bazel build //:fizz
bazel build //:wangle
bazel build //:mvfst

# Run tests
bazel test @folly_repo//...
bazel test @fizz_repo//...
```

## Available Libraries

| Target | Description |
|--------|-------------|
| `//:folly` | Facebook's core C++ library |
| `//:fizz` | TLS 1.3 implementation |
| `//:wangle` | Client/server application framework |
| `//:mvfst` | QUIC transport protocol |
| `//:proxygen` | HTTP library (HTTP/1.1, HTTP/2, HTTP/3) |
| `@libev_repo//:libev` | High-performance event loop |
| `@libevent//:libevent` | Event notification library |

## Using in Your Project

### 1. Add to your MODULE.bazel

```starlark
bazel_dep(name = "archelabs_proxygen_bld", version = "0.0.0")
git_override(
    module_name = "archelabs_proxygen_bld",
    remote = "https://github.com/AracheLabs/archelabs-proxygen_bld.git",
    commit = "<commit-hash>",
)
```

Or use `archive_override` / `local_path_override` as needed.

### 2. Add dependencies in your BUILD file

```starlark
cc_binary(
    name = "my_server",
    srcs = ["main.cpp"],
    deps = [
        "@archelabs_proxygen_bld//:proxygen",
        "@archelabs_proxygen_bld//:folly",
    ],
)
```

### Example: Using Proxygen HTTPServer

```cpp
#include <proxygen/httpserver/HTTPServer.h>
#include <proxygen/httpserver/RequestHandler.h>
#include <proxygen/httpserver/ResponseBuilder.h>

class MyHandler : public proxygen::RequestHandler {
 public:
  void onRequest(std::unique_ptr<proxygen::HTTPMessage> headers) noexcept override {}
  void onBody(std::unique_ptr<folly::IOBuf> body) noexcept override {}
  void onEOM() noexcept override {
    proxygen::ResponseBuilder(downstream_)
        .status(200, "OK")
        .body("Hello, World!")
        .sendWithEOM();
  }
  void onUpgrade(proxygen::UpgradeProtocol proto) noexcept override {}
  void requestComplete() noexcept override { delete this; }
  void onError(proxygen::ProxygenError err) noexcept override { delete this; }
};
```

### Example: Using Folly Futures

```cpp
#include <folly/futures/Future.h>
#include <folly/executors/GlobalExecutor.h>

folly::Future<int> asyncCompute() {
  return folly::via(folly::getGlobalCPUExecutor(), [] {
    return 42;
  });
}
```

### Example: Using Fizz TLS

```cpp
#include <fizz/client/FizzClientContext.h>
#include <fizz/protocol/DefaultCertificateVerifier.h>

auto ctx = std::make_shared<fizz::client::FizzClientContext>();
ctx->setSupportedVersions({fizz::ProtocolVersion::tls_1_3});
```

### Example: Using libev

```starlark
# BUILD file
cc_binary(
    name = "my_event_app",
    srcs = ["main.cpp"],
    deps = ["@libev_repo//:libev"],
)
```

```cpp
#include <ev.h>

int main() {
  struct ev_loop *loop = ev_default_loop(0);
  ev_run(loop, 0);
  return 0;
}
```

## Project Structure

```
├── MODULE.bazel          # Bazel module definition & dependencies
├── BUILD.bazel           # Root aliases (//:folly, //:proxygen, etc.)
├── bzl/                   # Helper macros
├── proxygen/
│   └── proxygen_repo.BUILD   # Proxygen BUILD overlay
└── thirdparty/
    ├── folly/folly_repo.BUILD
    ├── fizz/fizz_repo.BUILD
    ├── wangle/wangle_repo.BUILD
    ├── mvfst/mvfst_repo.BUILD
    └── *.BUILD               # Other dependencies
```

## License

Build files in this repository are provided under the same license as proxygen (BSD).
The libraries built are subject to their respective licenses.

Copyright (c) Arche Labs Inc., 2025-onward
