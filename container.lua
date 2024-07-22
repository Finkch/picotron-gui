--[[
    a visual or functional element within the gui

]]

Container = {}
Container.__index = Container
Container.__type = "container"
Container.__parenttype = "container"

function Container:new(x, y, width, height, cls, contents)
    local c = {
        x = x,              -- position within gui
        y = y,

        width = width,      -- size of container
        height = height,
        
        cls = cls,          -- colours to draw
        border = border,

        contents = contents,-- a draw function to call to draw its contents

        padding = 2,        -- size of border

        active   = true,    -- whether or not the content is interactable
        hovering = false,   -- whether or not the mouse is over this container
        clicking = false,   -- whether or not the mouse has clicked this container
        holding  = false,   -- whether or not the mouse is being held down on this container
        clicked  = false,   -- used for state (true on click until no longer holding)
    }

    setmetatable(c, Container)
    return c
end

-- determines whether the mouse is above the container
function Container:hover(gui)
    local pos = gui.kbm.pos
    return (
        pos.x > self.x - self.padding and
        pos.y > self.y - self.padding and
        pos.x < self.x + self.width + self.padding and
        pos.y < self.y + self.height + self.padding
    )
end

-- whether the container has been clicked (mouse down first frame)
function Container:click(gui)
    return self:hover(gui) and gui.kbm:pressed("lmb")
end

-- whether the container has been clicked (mouse down all frames)
function Container:hold(gui)
    return gui.kbm:down("lmb") > 0
end


-- returns coordinates
function Container:top(padding)
    padding = padding or 0
    if (padding > 0) padding -= self.padding
    return self.y - padding
end

function Container:right(padding)
    padding = padding or 0
    if (padding > 0) padding += self.padding
    return self.x + self.width + padding
end

function Container:bottom(padding)
    padding = padding or 0
    if (padding > 0) padding += self.padding
    return self.y + self.height + padding
end

function Container:left(padding)
    padding = padding or 0
    if (padding > 0) padding -= self.padding
    return self.x - padding
end

function Container:middle_vertical()
    return (2 * self.y + self.height) / 2
end

function Container:middle_horizontal()
    return (2 * self.x + self.width) / 2
end


-- moves the camera to the container
function Container:focus(style)
    if (not style) style = "tl"

    if (style == "tl") then
        camera(-self.x, -self.y)
    elseif (style == "c") then
        camera(-self:middle_horizontal(), -self:middle_vertical())
    end
end


-- updates
function Container:update(gui)
    self:update_active(gui)
    self:_update_active(gui)
    self:update_status(gui)

    if (self.clicking) then
        self:when_clicked(gui)
    else
        self:when_not_clicked(gui)
    end

    self:update_contents(gui)
    self:update_extra(gui)
end

function Container:update_status(gui)   -- mouse status

    if (not self.active) then
        self.hovering = false
        self.clicking = false
        self.holding =  false
        self.clicked =  false

    else
        self.hovering = self:hover(gui)
        self.clicking = self:click(gui)
        self.holding = self:hold(gui)

        if (self.clicking) self.clicked = true
        if (not self.holding) self.clicked = false
    end
end

function Container:update_contents(gui)          -- updates content
    if (self.contents) self.contents:update(gui)
end

-- can be overidden
function Container:update_active(gui) self.active = true end

-- deactivates if gui is in wrong mode
function Container:_update_active(gui)
    if (self.mode and gui.data.mode) self.active = self.active and gui.data.mode == self.mode
end


-- can be overridden to give more control
function Container:when_clicked(gui) end

function Container:when_not_clicked(gui) end

function Container:update_extra(gui) end


-- draws container & contents
function Container:draw(gui)

    -- resets palette
    pal()

    -- moves camera
    self:focus("tl")
    
    -- clears the screen
    rectfill(0, 0, self.width, self.height, self.cls)
        
    -- draws the border
    line(-1, -1, -1, self.height + 1, 5)
    line(-1, -1, self.width, -1, 5)

    line(self.width + 1, self.height + 1, 0, self.height + 1, 7)
    line(self.width + 1, self.height + 1, self.width + 1, -1, 7)



    -- centres container contents
    if (self.contents and self.contents.draw) then
        self:focus("c")
        self.contents:draw()
    end

    self:draw_extra(gui)
end

-- can be overridden to give more control
function Container:draw_extra(gui) end


--[[
    a label is a container whose contents are not updated.
    

]]

Label = {}
Label.__index = Label
Label.__type = "label"
setmetatable(Label, Container)

function Label:new(x, y, cls, contents, colour, width, height)

    -- gets the width and height
    local w, h = -1, -1
    local istext = nil                  -- whether contents is text or a sprite

    if (type(contents) == "string") then
        w, h = print(contents, 0, -20) + 4, 13
        istext = true 

    elseif (type(contents) == "number") then
        contents = get_spr(contents)    -- updates contents to be the sprite
        w, h = contents:width() + 3, contents:height() + 3
        istext = false
    end

    -- overrides width and height
    if (width)  w = width
    if (height) h = height


    local l = Container:new(x, y, w, h, cls, nil)
    l.istext = istext
    l.padding = 2
    l.colour = colour
    l.image = contents

    setmetatable(l, Label)
    return l
end

-- overrides Container update; does not update!
function Label:update_contents(gui) end

function Label:draw(gui)

    Container.draw(self)

    -- moves camera to topleft of container
    self:focus()

    -- swaps active colour for dark grey when not active
    if (not self.active) pal(self.colour, 5)

    -- draws button image
    if (self.istext) then
        print(self.image, 3, 3, self.colour)
    else
        spr(self.image, 2, 2)
    end
end




--[[
    a button is a contentless container that can be pressed

]]

Button = {}
Button.__index = Button
Button.__type = "button"
setmetatable(Button, Label)

function Button:new(x, y, cls, contents, colour, width, height)

    local b = Label:new(x, y, cls, contents, colour, width, height)

    setmetatable(b, Button)
    return b
end


function Button:update_contents(gui)
    if (self.clicking and self.contents and self.contents.update) self.contents:update(gui) 
end


-- completely overrides lower draws due to palette swapping issues
function Button:draw(gui)

    pal()
    if (not self.active) then
        pal(5, 0)
        pal(6, 5)
    end

    -- swaps colours to make it look asif button is rising from window
    if (not self.clicked and self.active) then
        pal(5, 7)
        pal(7, 5)
    end


    -- moves camera
    self:focus("tl")

    -- clears the screen
    rectfill(0, 0, self.width, self.height, self.cls)
        
    -- draws the border
    line(-1, -1, -1, self.height + 1, 5)
    line(-1, -1, self.width, -1, 5)

    line(self.width + 1, self.height + 1, 0, self.height + 1, 7)
    line(self.width + 1, self.height + 1, self.width + 1, -1, 7)

    -- draws button image
    if (self.istext) then
        print(self.image, 3, 3, self.colour)
    else
        spr(self.image, 2, 2)
    end


    -- two width border (other layer is from container draw)
    self:focus()
    line(0, 0, 0, self.height, 5)
    line(0, 0, self.width, 0, 5)

    line(self.width, self.height, 0, self.height, 7)
    line(self.width, self.height, self.width, 0, 7)

    -- adds mid-tone grey to two corners
    line(self.width + 1, -1, self.width, 0, 6)
    line(-1, self.height + 1, 0, self.height, 6)
end




--[[
    a slider is like a button to adjust values

]]

Slider = {}
Slider.__index = Slider
Slider.__type = "slider"
setmetatable(Slider, Container)

function Slider:new(x, y, length, vertical, minimum, maximum, step)
    
    local w, h = -1, -1
    if (vertical) then
        w = 0
        h = length
    else
        w = length
        h = 0
    end

    local s = Container:new(x, y, w, h, 0, nil)
    s.minimum = minimum
    s.maximum = maximum
    s.current = 0
    s.length = length
    s.vertical = vertical
    s.step = step               -- forces slider into discrete values of this size
    s.padding = 6
    s.when_clicked = nil        -- methods that can be set
    s.when_not_clicked = nil

    setmetatable(s, Slider)
    return s
end

-- alters input value to match discrete step size
function Slider:discretise(value)

    -- step / 10 is adding an arbitrarily small amount to avoid floating errors
    if (self.step) value = self.step * flr((value + self.step / 10) / self.step)

    return value
end


-- gets the current value out of the slider, mapped to its min and max
function Slider:get()
    return self:discretise(self.current * (self.maximum - self.minimum) + self.minimum)
end

-- places a value in, mapping into its min and max
function Slider:put(value)
    self.current = (self:discretise(value) - self.minimum) / (self.maximum - self.minimum)

    -- caps the value
    self.current = mid(0, self.current, 1)
end


-- overrides container's update
function Slider:update(gui)
    Container.update(self, gui)

    if (self.clicked) then
        self:update_slider(gui)

        self:when_clicked(gui)
    else
        self:when_not_clicked(gui)
    end
end

function Slider:update_slider(gui)
    -- transforms mouse position to 0-1 relative to slider
    local pos = gui.kbm.pos

    local s, e = -1, -1
    local c = -1
    local current = -1
    if (self.vertical) then
        s = self.y + self.length
        e = self.y
        c = pos.y

        current = (s - c) / self.length

    else
        s = self.x
        e = self.x + self.width
        c = pos.x

        current = 1 - (e - c) / self.length
    end

    -- clamps the values to 0-1
    current = mid(0, current, 1)

    self.current = current
end

-- increases current by the discrete step size
function Slider:stepup(gui)
    self:put(self:get() + self.step)

    -- updates whatever the slider is linked to
    if (self.when_clicked) self:when_clicked(gui)
end

function Slider:stepdown(gui)
    self:put(self:get() - self.step)
    
    -- updates whatever the slider is linked to
    if (self.when_clicked) self:when_clicked(gui)
end



function Slider:draw(gui)
    Container.draw(self)

    self:focus()

    local x, y = -1, -1
    local sx, sy = -1, -1
    if (self.vertical) then
        x = 0
        y = (1 - self.current) * self.length
    else
        x = self.current * self.length
        y = 0
    end

    -- swaps palette to show slider is deactivated
    if (not self.active) then
        pal(5, 0)
        pal(6, 5)
    end

    -- draws a circle at the current position
    spr(7, x - 6, y - 6)
end