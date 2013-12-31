solution "sln-eelua"
  configurations { "Release", "Debug" }

  include "deps/auxiliar"
  include "deps/lpack"
  include "deps/lpeg"
  include "deps/lirrxml"

  project "eelua"
    kind "SharedLib"
    language "C++"
    files { "src/*.cc" }

    includedirs { "include", "deps/auxiliar" }
    libdirs { "lib" }
    links { "auxiliar", "lua" }

    configuration "Debug"
       defines { "DEBUG" }
       flags { "Symbols" }

    configuration "Release"
       defines { "NDEBUG" }
       flags { "Optimize" }


  dofile("src/lua/embed.lua")

  newaction {
    trigger = "embed",
    description = "Embed scripts in scripts.c",
    execute = doembed
  }

