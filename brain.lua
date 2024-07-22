--[[
    gives logic to containers in the gui

]]



--[[
    generic brain

]]

Brain = {}
Brain.__index = Brain
Brain.__type = "brain"
Brain.__parenttype = "brain"

function Brain:new(target)
    local b = {
        target = target
    }

    setmetatable(b, Brain)
    return b
end

-- empty update functions. Must be overridden or given a new update function
function Brain:update(gui) end




--[[
    LabelBrains grab data from a slider (or really from anything)
    and push it into the label's readout

]]

LabelBrain = {}
LabelBrain.__index = LabelBrain
LabelBrain.__type = "labelbrain"
setmetatable(LabelBrain, Brain)

function LabelBrain:new(target, source, decimals)
    
    decimals = decimals or 0
    
    local lb = Brain:new(target)
    lb.source = source
    lb.decimals = decimals

    setmetatable(lb, LabelBrain)
    return lb
end

function LabelBrain:get(gui)
    return self.source:get(gui)
end

function LabelBrain:update(gui)
    local datum = self:get(gui)

    if (type(datum) == "number") datum = string.format("%." .. self.decimals .. "f", datum)

    self.target.image = datum
end
