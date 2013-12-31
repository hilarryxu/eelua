project "auxiliar"
  kind "StaticLib"
  language "C"
  files { "*.c" }

  includedirs { "../../include" }

  configuration "Debug"
     defines { "DEBUG" }
     flags { "Symbols" }

  configuration "Release"
     defines { "NDEBUG" }
     flags { "Optimize" }

