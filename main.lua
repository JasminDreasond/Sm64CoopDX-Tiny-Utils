-- name: \\#e39a1b\\! Tiny Utils - Jasmini Scripts ! \\#ffffff\\(v1.0)
-- description: Tiny lib of useful API codes to start moding Sm64CoopDX.

function load_setting(key, opts, default)
    local setting = math.floor(mod_storage_load_number(key))
    if setting <= 0 or setting > opts then
        return default
    else
        return setting
    end
end