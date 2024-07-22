--[[pod_format="raw",created="2024-07-01 19:40:30",modified="2024-07-10 22:40:16",revision=145]]
-- Metatable; effectively a class

-- 2d vectors

Vec = {}
Vec.__index = Vec
Vec.__type = "vec"


-- constructor
function Vec:new(x, y)
    x = x or 0
    y = y or 0
    local v = {x = x, y = y}
    setmetatable(v, Vec)
    return v
end


-- copies the vector
function Vec:copy()
    return Vec:new(
        self.x,
        self.y
    )
end


-- algebra
function Vec:__add(other)
    return Vec:new(
        self.x + other.x,
        self.y + other.y
    )
end

function Vec:__sub(other)
    return Vec:new(
        self.x - other.x,
        self.y - other.y
    )
end

function Vec:__mul(other)
    return Vec:new(
        self.x * other,
        self.y * other
    )
end

function Vec:__div(other)
    return Vec:new(
        self.x / other,
        self.y / other
    )
end

function Vec:__unm()
    return self * -1
end


-- vector operations
function Vec:mag()
    return (self.x ^ 2 + self.y ^ 2) ^ 0.5
end

function Vec:normal()
    return self / self:mag()
end

function Vec:rotate(r) -- r E [0, 1]
    return Vec:new(
        self.x * cos(r) - self.y * sin(r),
        self.x * sin(r) + self.y * cos(r)
    )
end

function Vec:dir() -- r E [0, 1]
    return atan2(self.y, self.x) + 0.5
end


-- vector-vector operations
-- note: we overload existing operators to do this
function Vec:__mod(other) -- dot product!
    return self.x * other.x + self.y * other.y
end

function Vec:__pow(other) -- cross product! points towards z
    return self.x * other.y - self.y * other.x
end


-- other metamethods
function Vec:__flr()
    return Vec:new(
        flr(self.x),
        flr(self.y)
    )
end

function Vec:__ceil()
    return Vec:new(
        ceil(self.x),
        ceil(self.y)
    )
end


-- comparison operators
function Vec:__eq(other)
    return self.x == other.x and self.y == other.y
end


-- tostring
function Vec:__tostring()
    return string.format("(%.2f, %.2f)", self.x, self.y)
end