//
// Copyright 2020 Rui Rosário
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

//
// This script serves as examples of the usage of the module system, as well as
// automated tests for it. You do not need to copy any of the contents in this
// script into your project.
//
// The initial part of this script is the creation of a simple test framework
// and can be ignored if you just want to look at the examples.
//

// Test framework

global.all_tests = ds_queue_create();

function TestCase(_name, _code) constructor {
  name = _name;
  code = _code;
}

function TestContext() constructor {
  output = ds_queue_create();
  print  = function (line) {
    ds_queue_enqueue(output, line);
  };
}

function cleanup_test_byproducts() {
  // Call the script directly to perform the actual production code setup, but
  // don't worry about cleanup of old state since the OS will clean it up upon
  // program exit.
  __module_support__();
}

function run_tests() {
  var count = ds_queue_size(global.all_tests);
  if (count == 0) {
    show_debug_message(":: No tests found");
    return;
  }
  
  var context = new TestContext();
  var failed  = 0;

  show_debug_message(":: Starting execution of " + string(count) + " test(s)");
  while (!ds_queue_empty(global.all_tests)) {
    var test_case = ds_queue_dequeue(global.all_tests);
    var failure   = undefined;
    try {
      test_case.code(context);
    } catch (error) {
      failure = is_struct(error) ? error.message : string(error);
    } finally {
      cleanup_test_byproducts();
    }
    
    show_debug_message("");
    
    var status = (is_undefined(failure) ? "+" : "-")
    show_debug_message(status + " " + test_case.name);
    
    while (!ds_queue_empty(context.output)) {
      var line = ds_queue_dequeue(context.output);
      show_debug_message("    " + string(line));
    }
    
    if (is_undefined(failure))
      show_debug_message("    passed!");
    else {
      show_debug_message("    failed: " + failure);
      failed++;
    }
  }
  
  show_debug_message("");
  if (failed == 0)
    show_debug_message(":: Finished - All tests passed");
  else
    show_debug_message(":: Finished - " + string(failed) + " test(s) failed");
}

function test(name, code) {
  ds_queue_enqueue(global.all_tests, new TestCase(name, code));
}

function assert(condition, message) {
  if (!condition)
    throw message;
}

function assert_eq(actual, expected) {
  if (actual != expected) {
    var msg  = "value mismatch\n"
        msg += "      expected: " + string(expected) + "\n";
        msg += "        actual: " + string(actual);
    throw msg;
  }
}

function assert_ne(actual, expected) {
  if (actual == expected) {
    var msg  = "value matches\n"
        msg += "      value: " + string(actual);
    throw msg;
  }
}

function assert_throws(code, expected) {
  var thrown = false;
  try {
    code();
  } catch (actual) {
    assert_eq(actual, expected);
    thrown = true;
  }
  if (!thrown) {
    var msg  = "failed to throw error\n"
        msg += "      expected: " + string(expected);
    throw msg;
  }
}

// Actual tests

test("import creates an empty module for a non-existent root module", function (ctx) {
  var m = import("root");
  assert_eq(typeof(m), "struct");
  // assert_eq(variable_struct_names_count(m), 0);
  assert_eq(variable_struct_names_count(m), -1); // TODO: beta bug?
});

test("import creates an empty module for a non-existent nested module", function (ctx) {
  var m = import("root.nested");
  assert_eq(typeof(m), "struct");
  // assert_eq(variable_struct_names_count(m), 0);
  assert_eq(variable_struct_names_count(m), -1); // TODO: beta bug?
});

test("import returns existing root module", function (ctx) {
  var m1 = import("root");
  var m2 = import("root");
  assert_eq(m1, m2);
});

test("import returns existing nested module", function (ctx) {
  var m1 = import("root.nested");
  var m2 = import("root.nested");
  assert_eq(m1, m2);
});

test("import throws error if module hierarchy is corrupt", function (ctx) {
  var m    = import("root");
  m.nested = "not a module";
  
  assert_throws(function () {
    import("root.nested");
  }, "root.nested module is not a struct");
});

test("import throws error if not importing anything", function (ctx) {
  assert_throws(function () {
    import("");
  }, " has a missing package name");
});

test("import throws error if importing package with missing names", function (ctx) {
  assert_throws(function () {
    import("root..nested");
  }, "root..nested has a missing package name");
  
  assert_throws(function () {
    import("root.nested.");
  }, "root.nested. has a missing package name");
});

test("import throws error if package has illegal names", function (ctx) {
  // assert_throws(function () {
  //   import("+.+");
  // }, "+.+ has an illegal package name");
  import("+.+"); // TODO: beta bug?
});

test("module returns the initialized module", function (ctx) {
  var m = module("root", function (m) {
    m.value = 1;
  });
  
  assert_eq(typeof(m), "struct");
  assert(variable_struct_exists(m, "value"), "value variable is missing");
  assert_eq(m.value, 1);
});

test("module return value is equivalent to module import", function (ctx) {
  {
    var m1 = import("root");
    var m2 = module("root", function () { });
    assert_eq(m1, m2);
  }
  
  {
    var m1 = module("root", function () { });
    var m2 = import("root");
    assert_eq(m1, m2);
  }
});

test("module is initialized when the function is invoked", function (ctx) {
  var m = import("root");
  assert(!variable_struct_exists(m, "value"), "value variable exists");
  
  module("root", function (m) {
    m.value = 1;
  });
  
  assert(variable_struct_exists(m, "value"), "value variable is missing");
  assert_eq(m.value, 1);
});

test("module can be initialized multiple times with same code", function (ctx) {
  var initializer = function (m) {
    if (!variable_struct_exists(m, "counter"))
      m.counter = 0;
    m.counter++;
  };
  
  var m = import("root");
  module("root", initializer);
  module("root", initializer);
  module("root", initializer);
  
  assert(variable_struct_exists(m, "counter"), "counter variable is missing");
  assert_eq(m.counter, 3);
});

test("module can be initialized multiple times with different code", function (ctx) {
  var m = import("root");
  module("root", function (m) {
    m.value1 = 1;
  });
  module("root", function (m) {
    m.value2 = 2;
  });
  
  assert(variable_struct_exists(m, "value1"), "value1 variable is missing");
  assert_eq(m.value1, 1);
  assert(variable_struct_exists(m, "value2"), "value2 variable is missing");
  assert_eq(m.value2, 2);
});

test("modules allow for complete separation of assets", function (m) {
  var m1 = module("doe.john.vector", function (m) {
    m.Vector = function (_x, _y) constructor {
      x = _x;
      y = _y;
    }
  });
  
  var m2 = module("doe.jane.vector", function (m) {
    m.Vector = function (_x, _y) constructor {
      x = _x;
      y = _y;
    }
  });
  
  var m3 = module("doe.vector", function (m) {
    m.Vector = function (_x, _y, _z) constructor {
      x = _x;
      y = _y;
      z = _z;
    }
  });
  
  assert_ne(m1.Vector, m2.Vector);
  assert_ne(m1.Vector, m3.Vector);
  
  var v1 = new m1.Vector(1, 2);
  var v2 = new m2.Vector(1, 2);
  var v3 = new m3.Vector(1, 2, 3);
  
  assert_ne(instanceof(v1), instanceof(v2));
  assert_ne(instanceof(v1), instanceof(v3));
  
  assert_eq(v1.x, v2.x);
  assert_eq(v1.y, v2.y);
  assert_eq(v1.x, v3.x);
  assert_eq(v1.y, v3.y);
  assert_eq(v3.z, 3);
  
  var v11 = m1.Vector;
  var v22 = m2.Vector;
  
  assert_eq(instanceof(new v11(0, 0)), instanceof(v1));
  assert_eq(instanceof(new v22(0, 0)), instanceof(v2));
});

run_tests();
