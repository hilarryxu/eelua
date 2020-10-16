eelua
=====

A lua script engine for [EverEdit](http://www.everedit.net/).

Features
--------

    1. Most feature same as EverEdit's internal script engine(vbs, jscript)
    2. Lua scriprts just like scripts in EverEdit's macro dir
    3. Plugin architecture for large script bundle
    4. An `dofile` function can called in EverEdit's mode file

System Requirements
-------------------

For now, I use mingw and xmake build it.

- [mingw](http://www.mingw.org/)
- [premake5](https://github.com/premake/premake-core)

Build
-----

```
premake5 gmake
make
```

Installation
------------

Copy `lua51.dll` to EverEdit's dir, copy `eelua.dll` to EverEdit's plugin dir (create it if not exist), then
copy `eelua` dir to EverEdit's dir, just like:

```
EverEdit/
  everedit.exe
  lua51.dll
  plugin/
    eelua.dll
  eelua/
    eelua_init.lua  # user's init lua script
    scripts/  # scripts
```

Usage
-----

TODO
----

License
-------

eelua is made available under the terms of MIT license. See the LICENSE file that accompanies this distribution for the full text of the license.

