solution "sln-eelua"
  configurations { "Release", "Debug" }

  project "eelua"
    kind "SharedLib"
    language "C"
    files { "src/*.c" }

    includedirs { "include" }
    libdirs { "lib" }
    links { "lua51" }

    configuration "Debug"
       defines { "DEBUG" }
       symbols "On"

    configuration "Release"
       defines { "NDEBUG" }
       optimize "On"
