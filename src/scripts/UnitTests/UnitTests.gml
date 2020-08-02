
test("Integrity Checks are enabled", function() {
  assert_eq(true, GM_MODULE_SYSTEM__ENABLE_INTEGRITY_CHECKS);
});

test("Integrity Checks pass by default", function() {
  global.__module_context__.self_test();
});

test("Module Structure Validation is enabled", function() {
  assert_eq(true, GM_MODULE_SYSTEM__VALIDATE_MODULE_STRUCTURE);
});

test("Module Structure Validation accepts default Module", function() {
  global.__module_context__.validate(new Module("test"));
});
