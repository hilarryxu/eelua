project "lirrxml"
  kind "SharedLib"
  language "C++"
  targetdir "../../eelua"
  files { "*.cpp" }

  includedirs { "../../include", "../auxiliar" }
  libdirs { "../../lib" }
  links { "auxiliar", "lua" }

  configuration "Debug"
     defines { "DEBUG" }
     flags { "Symbols" }

  configuration "Release"
     defines { "NDEBUG" }
     flags { "Optimize" }

