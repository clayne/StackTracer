-- set minimum xmake version
set_xmakever("2.7.8")

-- set project
set_project("stack-tracer")
set_version("1.0.0")
set_license("MIT")
set_languages("c++23")
set_optimize("faster")
set_warnings("allextra", "error")

-- set allowed
set_allowedarchs("windows|x64")
set_allowedmodes("debug", "releasedbg")

-- set defaults
set_defaultarchs("windows|x64")
set_defaultmode("releasedbg")

-- add rules
add_rules("mode.debug", "mode.releasedbg")
add_rules("plugin.vsxmake.autoupdate")
add_rules("plugin.compile_commands.autoupdate", { lsp = "clangd" })

-- set policies
set_policy("package.requires_lock", true)

-- require packages
add_requires("commonlibsse-ng", { configs = { skyrim_vr = false } })

-- targets
target("stack-tracer")
    -- add packages to target
    add_packages("fmt", "spdlog", "commonlibsse-ng")

    -- add commonlibsse-ng plugin
    add_rules("@commonlibsse-ng/plugin", {
        name = "stack-tracer",
        author = "digital-apple"
    })

    -- add src files
    add_files("source/**.cpp")
    add_headerfiles("include/**.h")
    add_includedirs("include", "source")
    set_pcxxheader("include/PCH.h")

    -- copy build files to MODS or SKYRIM paths (remove if not needed)
    after_build(function(target)
        local copy = function(env, ext)
            for _, env in pairs(env:split(";")) do
                if os.exists(env) then
                    local plugins = path.join(env, ext, "SKSE/Plugins")
                    os.mkdir(plugins)
                    os.trycp(target:targetfile(), plugins)
                    os.trycp(target:symbolfile(), plugins)
                end
            end
        end
        if os.getenv("SKYRIM_MODS_PATH") then
            copy(os.getenv("SKYRIM_MODS_PATH"), target:name())
        elseif os.getenv("SKYRIM_PATH") then
            copy(os.getenv("SKYRIM_PATH"), "Data")
        end
    end)
