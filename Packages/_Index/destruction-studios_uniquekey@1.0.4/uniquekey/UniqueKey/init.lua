local function UniqueKey(keyName:string)
    assert(typeof(keyName) == "string", `UniqueKey name must be of type 'string' got {typeof(keyName)}`)

    local uniqueKey = newproxy(true)

    getmetatable(uniqueKey).__tostring = function()
        return `UniqueKey<{keyName}>`
    end

    return uniqueKey
end


return UniqueKey