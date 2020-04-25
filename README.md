# GameMaker Module System

With the new GameMaker: Studio 2.3 version we have access to structs.
These are dynamic data containers that unlike objects have no kind of default processing associated with them.
This makes them ideal for storing a lot of information.
Furthermore, they not only allow data storage but also behavior storage by storing a function in a variable.

All of this allows us to create a module system where each package is isolated within its own scope.
A major advantage over current marketplace asset structure or game modules that need to have convoluted naming schemes in order to not cause any conflicts.

## Scenario

Imagine that you created your own vector library for use in your game:
```gml
function Vector(_x, _y) constructor {
    x = _x;
    y = _y;
    
    plus = function(vector) {
        return new Vector(x + vector.x, y + vector.y);
    }

    // ...
}
```

Then you import a Marketplace asset for 3D rendering that looks like:
```gml
function Mesh(...) constructor {
    // ...
}

function Vector(_x, _y, _z) constructor {
    x = _x;
    y = _y;
    z = _z;
    
    plus = function(vector) {
        x += vector.x;
        y += vector.y;
        z += vector.z;
    }

    // ...
}
```

And now you have a collision between both versions of `Vector`!
You could decide that having an extra coordinate would be ok, so you could delete your version.
However, note that even the _semantics_ of the `plus` method is different (yours was immutable).
If you just decide to use the imported `Vector` version then your code might stop working, but if you keep your version and add a `z` coordinate to it then the imported code might stop working!

### The Solution

You could avoid having this conflict in the first place if you defined your vector library in a module:
```gml
module("doe.john.vector", function (m) {
    m.Vector = function (_x, _y) constructor {
        x = _x;
        y = _y;
        // ...
    }
    // ...
});

// To use it you could...
{
    // Store the returned module reference from the call above
    var m = module("doe.john.vector", function (m) { ... });
    show_debug_message(new m.Vector(0, 0));
}
{
    // Import the module reference and store it for later reference
    var m = import("doe.john.vector");
    show_debug_message(new m.Vector(0, 0));
}
{
    // Import the module reference inline with the usage
    show_debug_message(new import("doe.john.vector").Vector(0, 0));
}
```

If your code was modularized then importing the Marketplace asset would yield absolutely no conflict!
Your `Vector` implementation would be self-contained in the module's scope while the imported implementation would be available in the global scope as usual.
But it is possible that the asset was modularized as well:
```gml
module("doe.jane.vector", function (m) {
    m.Vector = function (_x, _y, _z) constructor {
        x = _x;
        y = _y;
        z = _z;
        // ...
    }
    // ...
});

module("doe.jane.rendering", function (m) {
    m.Mesh = function (...) constructor {
        // ...
    }
    // ...
});
```

Note that even though there is a common package portion (`doe.`) both vector modules are still in different scopes.
You can find a more involved example of this in the [test suite](scripts/__module_support__tests__/__module_support__tests__.gml).

## Notice

GameMaker: Studio 2.3 is still in beta testing.
Therefore, the features used in this library might not be final.
An effort will be made to keep up with any updates to the beta version of GameMaker, however the API of this library might break until GameMaker itself reaches a stable release milestone.
Due to this, any released version of this library with a version below `1.0.0` will not follow semantic versioning and breaking changes may be introduced at any version number change.