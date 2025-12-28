/*
 * Custom test main for folly tests that require folly::Init.
 *
 * Many folly tests use singletons that require folly::Init to be called
 * before the singleton registration is complete. Using gtest_main doesn't
 * call folly::Init, causing these tests to fail with:
 * "Singleton XXX requested before registrationComplete() call"
 *
 * This file provides a test main that calls folly::Init before running tests.
 */

#include <gtest/gtest.h>
#include <folly/init/Init.h>

int main(int argc, char** argv) {
  testing::InitGoogleTest(&argc, argv);
  folly::Init init(&argc, &argv);
  return RUN_ALL_TESTS();
}
