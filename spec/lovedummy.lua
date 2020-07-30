--[[
    A dummy library for LOVE. Allows testing lua code that
    depends on LOVE, without needing to run the LOVE
    executable.
    The module returns a table that has all of the LOVE library
    interface defined, but with dummy function calls.
    (WIP)
]]

return {
    graphics={
        newFont=function() return {} end,
        newCanvas=function() return {} end,
        setDefaultFilter=function() return end,
        getWidth=function() return 1 end,
        getHeight=function() return 1 end,
        newQuad=function() return {} end,
        setColor=function() return end,
        getFont=function() return {} end,
        newText=function() return {} end
    },
    load=function() return end,
    update=function() return end,
    draw=function() return end,
    keypressed=function() return end,
    keyreleased=function() return end,
    filesystem={
        write=function() return true end,
        newFileData=function() 
            return {
                getPointer=function() return end,
                getSize=function() return 0 end
            } 
        end,
        read=function() return end
    },
    getVersion=function() return 11, 3, 1 end
}
