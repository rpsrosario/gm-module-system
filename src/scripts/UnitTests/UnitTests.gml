#region Integrity Checks

test("Integrity Checks are enabled by default", function() {
  assert(GM_MODULE_SYSTEM__ENABLE_INTEGRITY_CHECKS, "disabled");
});
test("-- checks pass by default", function() {
  global.__module_context__.self_test();
});

#endregion
#region Module Structure Validation

test("Module Structure Validation is enabled by default", function() {
  assert(GM_MODULE_SYSTEM__VALIDATE_MODULE_STRUCTURE, "disabled");
});
test("-- accepts struct with valid fields", function() {
  global.__module_context__.validate({
    name: "name",
    dependencies: [],
    is_loaded: false,
    on_load: function() { },
    on_unload: function() { },
  });
});
test("-- fails unless a struct is supplied", function() {
  assert_throws("reference is not a struct: string", function() {
    global.__module_context__.validate("test");
  });
});
test("-- fails if the struct is missing a name", function() {
  assert_throws("name variable is missing", function() {
    global.__module_context__.validate({
      dependencies: [],
      is_loaded: false,
      on_load: function() { },
      on_unload: function() { },
    });
  });
});
test("-- fails if the struct is missing a set of dependencies", function() {
  assert_throws("dependencies variable is missing", function() {
    global.__module_context__.validate({
      name: "name",
      is_loaded: false,
      on_load: function() { },
      on_unload: function() { },
    });
  });
});
test("-- fails if the struct is missing the loaded flag", function() {
  assert_throws("is_loaded variable is missing", function() {
    global.__module_context__.validate({
      name: "name",
      dependencies: [],
      on_load: function() { },
      on_unload: function() { },
    });
  });
});
test("-- fails if the struct is missing the loading method", function() {
  assert_throws("on_load variable is missing", function() {
    global.__module_context__.validate({
      name: "name",
      dependencies: [],
      is_loaded: false,
      on_unload: function() { },
    });
  });
});
test("-- fails if the struct is missing the unloading method", function() {
  assert_throws("on_unload variable is missing", function() {
    global.__module_context__.validate({
      name: "name",
      dependencies: [],
      is_loaded: false,
      on_load: function() { },
    });
  });
});
test("-- fails on a struct with an invalid name", function() {
  assert_throws("name is not a string: undefined", function() {
    global.__module_context__.validate({
      name: undefined,
      dependencies: [],
      is_loaded: false,
      on_load: function() { },
      on_unload: function() { },
    });
  });
});
test("-- fails on a struct with an invalid set of dependencies", function() {
  assert_throws("dependencies is not an array: number", function() {
    global.__module_context__.validate({
      name: "name",
      dependencies: ds_list_create(), // cleaned up by OS after process exit
      is_loaded: false,
      on_load: function() { },
      on_unload: function() { },
    });
  });
});
test("-- fails on a struct with an invalid dependency", function() {
  assert_throws("1: dependency is not a string: undefined", function() {
    global.__module_context__.validate({
      name: "name",
      dependencies: ["module-1", undefined, "module-2"],
      is_loaded: false,
      on_load: function() { },
      on_unload: function() { },
    });
  });
});
test("-- fails on a struct with an invalid loaded flag", function() {
  assert_throws("is_loaded is not a boolean: string", function() {
    global.__module_context__.validate({
      name: "name",
      dependencies: [],
      is_loaded: "false",
      on_load: function() { },
      on_unload: function() { },
    });
  });
});
test("-- fails on a struct with an invalid loading method", function() {
  assert_throws("on_load is not a method: undefined", function() {
    global.__module_context__.validate({
      name: "name",
      dependencies: [],
      is_loaded: false,
      on_load: undefined,
      on_unload: function() { },
    });
  });
});
test("-- fails on a struct with an invalid unloading method", function() {
  assert_throws("on_unload is not a method: undefined", function() {
    global.__module_context__.validate({
      name: "name",
      dependencies: [],
      is_loaded: false,
      on_load: function() { },
      on_unload: undefined,
    });
  });
});
test("-- accepts default Module struct with a valid name", function() {
  global.__module_context__.validate(new Module("name"));
});

#endregion
