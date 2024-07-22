--[[
    handles keyboard and mouse
]]

include("gui/vec.lua")

KBM = {}
KBM.__index = KBM


-- a class to track keyboard state
function KBM:new(buttons)

    local k = {
        spos = Vec:new(), -- screen coordinates
        pos  = Vec:new(), -- map coordinates
        keys = {}
    }

    -- gives each button some info
    for i = 1, #buttons do
        k.keys[buttons[i]] = {
            down        = 0,        -- frames button has been held down
            up          = 0,        -- frames the button has been up
            held        = false,    -- whether the button is currently down
            pressed     = false,    -- whether the button was initially pressed this frame
            released    = false,    -- whether the button was released this frame
        }
    end

    setmetatable(k, KBM)
    return k
end


-- checks status of each key being tracked
function KBM:update()

    -- gets mouse state
    local cx, cy, mb = mouse()

    -- updates mouse position
    self.spos = Vec:new(cx, cy)
    self.pos  = self.spos
    if (cam) self.pos += cam.pos


    -- updates all keys
    for k, v in pairs(self.keys) do

        -- checks if the key is down
        local kd = nil
        if (k == "lmb") then
            kd = mb & 0b1 != 0
        elseif (k == "rmb") then
            kd = mb & 0b2 != 0
        else
            kd = key(k)
        end

        -- handles both cases for key up and down
        if (kd) then
            v.held = true

            -- checks if the key was pressed this frame
            v.pressed = v.down == 0

            -- increments frames pressed down
            v.down  += 1
            v.up    =  0

        else
            v.held = false

            -- checks if the key was released this frame
            v.released = v.up == 0

            -- resets frames count
            v.down  =  0
            v.up    += 1
 
        end
    end
end

-- functions to easily check status of a key
function KBM:down(key)
    return self.keys[key].down
end

function KBM:up(key)
    return self.keys[key].up
end

function KBM:held(key)
    return self.keys[key].held
end

function KBM:pressed(key)
    return self.keys[key].pressed
end

function KBM:released(key)
    return self.keys[key].released
end
