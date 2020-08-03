#region Test Framework

///
/// List with all of the registered tests. Not cleaned up as the OS will
/// reclaim all memory allocated by the process either way.
///
global.tests = ds_list_create();

///
/// Structure used for storing test information
///
function Test() constructor {
  /// Descriptive name of the test
  name = undefined;
  /// Code to execute for the test - exception thrown means failure
  code = undefined;
  /// Time (in μs) that the test took to execute
  time = undefined;
}

function assert_eq(expected, actual) {
  if (expected != actual) {
    var typeE = typeof(expected);
    var typeA = typeof(actual);
    
    var message = "";
    message += "  expected: (" + typeE + ") " + string(expected) + "\n";
    message += "    actual: (" + typeA + ") " + string(actual);
    throw message;
  }
}

function assert_throws(expected, code) {
  try {
    code();
    throw "  nothing was thrown";
  } catch (e) {
    if (is_struct(e) && variable_struct_exists(e, "message"))
      e = e.message;
    assert_eq(expected, e);
  }
}

function assert(condition, message) {
  if (!condition) {
    throw "  " + message;
  }
}

///
/// Utility function to create a test structure
///
function __test(name, code) {
  var new_test = new Test();
  new_test.name = name;
  new_test.code = code;
  ds_list_add(global.tests, new_test);
}

///
/// Macro to circumvent GM not declaring above functions as actual functions
///
#macro test if (argument_count > 0) argument[0]

#endregion
#region Test Execution

// Register the tests - only works on VM
UnitTests(__test);

var helpers = {
  format_number: function(number) {
    number = string(number);
    var next = string_length(number) - 2;
    while (next > 1) {
      number = string_insert(" ", number, next);
      next -= 3;
    }
    return number;
  },
  print_separator: function(text, separator) {
    text = string(text);
    separator = is_undefined(separator) ? "=" : string_char_at(separator, 1);
    if (string_length(text) <= 96) {
      text = " " + text + " ";
      if (string_length(text) % 2 != 0)
        text += separator;
      var count = (100 - string_length(text)) / 2;
      var part = string_repeat(separator, count);
      text = part + text + part;
    }
    show_debug_message(text);
  },
  print_header: function(count) {
    var header = count == 1
      ? "Executing 1 test"
      : "Executing " + format_number(count) + " tests";
    show_debug_message("");
    print_separator(header);
  },
  print_footer: function(execution_time) {
    var footer = "Total time: " + format_number(execution_time)+ " μs";
    print_separator(footer);
    show_debug_message("");
  },
};

var test_count = ds_list_size(global.tests);
var test_execution_time = -1;

helpers.print_header(test_count);

test_execution_time = get_timer();
for (var i = 0; i < test_count; i++) {
  var next_test = global.tests[| i];
  
  var test_start = get_timer();
  var test_error = undefined;
  try {
    next_test.code();
  } catch (error) {
    if (is_struct(error) && variable_struct_exists(error, "message"))
      error = error.message;
    test_error = string(error);
  }
  next_test.time = get_timer() - test_start;
  
  var summary = is_undefined(test_error) ? "✓" : "❌";
  summary += " " + next_test.name;
  summary += " (" + helpers.format_number(next_test.time) + " μs)";
  show_debug_message(summary);
  
  if (!is_undefined(test_error))
    show_debug_message(test_error);
}
test_execution_time = get_timer() - test_execution_time;

helpers.print_footer(test_execution_time);
game_end();

#endregion
