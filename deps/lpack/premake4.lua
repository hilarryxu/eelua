project "lpack"
  kind "SharedLib"
  language "C"
  targetdir "../../eelua"
  files { "*.c" }

  includedirs { "../../include" }
  libdirs { "../../lib" }
  links { "lua" }

  configuration "Debug"
     defines { "DEBUG" }
     flags { "Symbols" }

  configuration "Release"
     defines { "NDEBUG" }
     flags { "Optimize" }

