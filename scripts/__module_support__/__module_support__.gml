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
// This script adds module support to GameMaker: Studio 2.3
//
// To "install" you just need to place this code in a script resource, you
// don't to need invoke the script since the necessary code is run at global
// scope automatically.
//

// This is the global structure used to hold all of the actual modules logic.
// You shouldn't reference it directly unless you know what you are doing very
// well!
global.__modules = {};

// This is a global DS Map used for caching module packages that are accessed
// frequently. Do not reference or manipulate it directly unless you know what
// you are doing very well!
global.__modules_cache = ds_map_create();

/// @function import(package)
/// @param {string} package
///   The package of the module to import.
/// @returns
///   The module with the specified package (which is actually a struct). Note
///   that structs are not immutable so do not edit the returned struct as to
///   do so might break the imported module!
/// @description
///   This function will "import" the module with the given package name.
///   Packages are hierarchical and a dot is used to separate its name
///   components. A name component follows the same rules a GameMaker's
///   variable name follows.
function import(package) {
  if (ds_map_exists(global.__modules_cache, package))
    return global.__modules_cache[? package];
  
  // If the module is not cached then we need to compute it. It might be that
  // the corresponding module still hasn't been initialized. In this case the
  // struct will either not exist or not have the necessary data in it. To
  // safeguard against this we will create any missing modules that we
  // traverse. Even if the module didn't exist before it will be created and
  // its reference reused when the module actually gets initialized, so it will
  // be safe to return the newly created struct.
  
  var parts = array_create(string_count(".", package) + 1);
  var count = array_length(parts);
  
  if (count == 1)
    parts[0] = package;
  else {
    var ind = 0;
    var rem = package;
    var sep = string_pos(".", rem);
    
    while (sep != 0) {
      parts[ind++] = string_copy(rem, 1, sep - 1);
      rem = string_copy(rem, sep + 1, string_length(rem) - sep);
      sep = string_pos(".", rem);
    }
    parts[ind] = rem;
  }
  
  var current = global.__modules;
  for (var i = 0; i < count; i++) {
    var pkg = parts[i];
    if (string_length(pkg) == 0)
      throw package + " has a missing package name";
    if (!variable_struct_exists(current, pkg)) {
      try {
        variable_struct_set(current, pkg, {});
      } catch (_) {
        throw package + " has an illegal package name";
      }
    }
    current = variable_struct_get(current, pkg);
    if (!is_struct(current)) {
      var path = "";
      for (var j = 0; j <= i; j++) {
        if (j > 0) path += ".";
        path += parts[j];
      }
      throw path + " module is not a struct";
    }
  }
  
  // This package was requested explicitly so it is likely that it is accessed
  // frequently, so cache it.
  global.__modules_cache[? package] = current;
  return current;
}

/// @function module(package, initializer)
/// @param {string} package
///   The package of the module to define.
/// @param {function} initializer
///   The function to initialize the module with.
/// @returns
///   The defined module as if import was invoked on its package.
/// @description
///   This function will define the module with the given package name.
///   Packages are hierarchical and a dot is used to separate its name
///   components. A name component follows the same rules a GameMaker's
///   variable name follows. Note that the module initializer will receive
///   exactly one argument: the struct reference of the module. This means that
///   if the module has been previously initialized then the reference to the
///   already initialized module will be returned, which can be used as a means
///   to expand the feature set of an existing module.
function module(package, initializer) {
  var m = import(package);
  initializer(m);
  return m;
}
