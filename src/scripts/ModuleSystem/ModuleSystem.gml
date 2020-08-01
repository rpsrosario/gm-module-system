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
/// Whether extended integrity checks should be compiled into the module system
/// or not.
///
/// Enabling this option will include a series of checks that were devised to
/// ensure the integrity of the module system as well as provide to the user
/// explicit error messages whenever such integrity is violated. This means
/// that these checks may have a significant impact on the game, therefore it
/// is recommended that such checks are disabled on production builds of the
/// game. Otherwise it is recommended to keep these checks enabled on debug
/// builds of the game unless the performance impact is critical. If that is
/// the case then at the very least enable the checks when writing/updating
/// code that makes active use of the module system so as to ensure proper
/// usage.
///
/// Note: This should be set to a compile time boolean constant, otherwise
/// unwanted side effects may occur.
///
#macro GM_MODULE_SYSTEM__ENABLE_INTEGRITY_CHECKS true

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

#endregion
#region Module System Framework
#endregion
