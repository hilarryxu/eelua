-- xmake f -p mingw -a x86_64

if is_mode("release") then
    add_defines("NDEBUG")
    set_symbols("hidden")
    set_strip("all")
    set_optimize("smallest")
end

add_subdirs "deps/auxiliar"

target "eelua"
    set_strip("all")
    set_kind "shared"
    add_files "src/*.cc"

    add_includedirs "include"
    add_includedirs "deps/auxiliar"

    add_linkdirs "$(buildir)"
    add_links "auxiliar"
    add_links "lua"

    after_build(function (target)
        os.mv(target:targetfile(), string.format("$(buildir)/%s.dll", target:name()))
    end)