//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// UNSUPPORTED: c++03

// test that referencing at_quick_exit when TEST_HAS_QUICK_EXIT is not defined
// results in a compile error.

#include <cstdlib>

#include "test_macros.h"

void f() { }

int main(int, char**) {
#if !defined(TEST_HAS_QUICK_EXIT)
    std::at_quick_exit(f);
#else
#   error
#endif
    return 0;
}
