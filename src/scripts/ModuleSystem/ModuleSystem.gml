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

#region Configuration Options

///
/// Whether extended integrity checks are performed.
///
/// Enabling this option will include a series of checks that were devised to
/// ensure the integrity of the module system. If this integrity is
/// compromised then the module system may become unstable and break in
/// unforeseen ways.
///
/// It is recommended to leave these checks enabled in all builds except the
/// final production builds. However, these checks can be costly. If the impact
/// is severe then the checks should be disabled by default. In this case they
/// should be re-enabled when working on code that actively uses the module
/// system in order to ensure its proper usage.
///
/// Note: This should be set to a compile time boolean constant, otherwise
/// unwanted side effects may occur and unnecessary code will be compiled into
/// the final distribution.
///
#macro GM_MODULE_SYSTEM__ENABLE_INTEGRITY_CHECKS true

///
/// Whether structural validation of the modules is performed.
///
/// Enabling this option will include a series of checks that validate that any
/// supplied structure is structurally equivalent to a module. Since modules do
/// not need to be structures from the official Module type (or any subtypes)
/// they need to be validated for the correct fields. The module system may
/// become unstable and break in unforeseen ways if the supplied structures do
/// not comply with the expected fields.
///
/// It is recommended to leave these checks enabled in all builds except the
/// final production builds. However, these checks can be costly. If the impact
/// is severe then the checks should be disabled by default. In this case they
/// should be re-enabled when working on code that actively uses the module
/// system in order to ensure its proper usage.
///
/// Note: This should be set to a compile time boolean constant, otherwise
/// unwanted side effects may occur and unnecessary code will be compiled into
/// the final distribution.
///
#macro GM_MODULE_SYSTEM__VALIDATE_MODULE_STRUCTURE true

#endregion
#region Global Context

/* internal usage - do not use unless you know what you're doing */
global.__module_context__ = {
};

if (GM_MODULE_SYSTEM__ENABLE_INTEGRITY_CHECKS) {
  var self_test = method(global.__module_context__, function() {
  });
  
  /* internal usage - do not use unless you know what you're doing */
  global.__module_context__.self_test = self_test;
}

if (GM_MODULE_SYSTEM__VALIDATE_MODULE_STRUCTURE) {
  var validate = method(global.__module_context__, function(ref) {
    if (!is_struct(ref))
      throw "Reference is not a struct (" + typeof(ref) + ")";
    var names = ["name", "dependencies", "is_loaded", "on_load", "on_unload"];
    for (var i = 0; i < array_length(names); i++) {
      if (!variable_struct_exists(ref, names[i]))
        throw names[i] + " variable is missing in " + instanceof(ref);
    }
    if (!is_string(ref.name))
      throw "name is not a string in " + instanceof(ref);
    if (!is_array(ref.dependencies))
      throw "dependencies is not an array in " + instanceof(ref);
    for (var i = 0; i < array_length(ref.dependencies); i++) {
      if (!is_string(ref.dependencies[i]))
        throw "dependency is not a string: " + string(ref.dependencies[i]);
    }
    if (ref.is_loaded != false && ref.is_loaded != true)
      throw "is_loaded is not a boolean in " + instanceof(ref);
    if (!is_method(ref.on_load))
      throw "on_load is not a method in " + instanceof(ref);
    if (!is_method(ref.on_unload))
      throw "on_unload is not a method in " + instanceof(ref);
  });
  
  /* internal usage - do not use unless you know what you're doing */
  global.__module_context__.validate = validate;
}

#endregion
#region Module System Framework

///
/// A module used by the Module System.
///
/// It is not required for a registered module to be of this type or even a
/// subtype of it. However, it is required that whatever structure is used
/// instead is structurally equivalent to a Module. This means that it should
/// at the very least have all of the fields defined in Module and they must
/// have the correct types. The module system itself can perform this
/// validation if GM_MODULE_SYSTEM__VALIDATE_MODULE_STRUCTURE is enabled.
///
/// Note: All of the expected fields should be treated as read only. They can
/// be set as part of the construction of the module (i.e. initial module
/// configuration) but they should never be updated by user code afterwards.
/// Doing so may make the module system unstable and break in unforeseen ways.
///
/// @function Module
/// @param name - The unique name of the module
///
function Module(name) constructor {
  ///
  /// The unique name of the module. This name is used by the module system for
  /// storage and identification purposes. It is also the value that must be
  /// used when declaring a direct dependency.
  ///
  self.name = name;
  ///
  /// An array with the direct dependencies of this module. All of the modules
  /// with the names supplied in this array must be loaded before this module
  /// can be itself loaded. May be empty if this module is independent of any
  /// other modules.
  ///
  dependencies = [];
  ///
  /// Whether this module has already been loaded or not. If no loading of the
  /// module is required and it has no dependencies then it may be set as true
  /// to avoid unnecessary processing. Otherwise it should be set to false.
  ///
  is_loaded = false;
  ///
  /// Method to invoke when the module is loaded. It is guaranteed that all of
  /// the module's dependencies have been loaded by the time this method is
  /// invoked.
  ///
  static on_load = function() { };
  ///
  /// Method to invoke when the module is unloaded. It is guaranteed that none
  /// of the module's dependencies have been unloaded yet by the time this
  /// method is invoked.
  ///
  static on_unload = function() { };
}

#endregion
