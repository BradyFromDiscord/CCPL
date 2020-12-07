local tex = require("/ccpl")("tex")

local checked = {}
local mined = {}

local function alreadyQueued(dig, direction)
    local currPos = tex.getPosition()
    local currDir = tex.getDirection()
    local index
    if direction == "forward" then
        index = textutils.serialise({ x=currPos.x+currDir.x, y=currPos.y, z=currPos.z+currDir.z })
    elseif direction == "up" then
        index = textutils.serialise({ x=currPos.x, y=currPos.y+1, z=currPos.z })
    elseif direction == "down" then
        index = textutils.serialise({ x=currPos.x, y=currPos.y-1, z=currPos.z })
    elseif direction == "left" then
        index = textutils.serialise({ x=currPos.x-currDir.z, y=currPos.y, z=currPos.z+currDir.x })
    elseif direction == "right" then
        index = textutils.serialise({ x=currPos.x+currDir.z, y=currPos.y, z=currPos.z-currDir.x })
    end
    if dig then
        if mined[index] then return true end
        mined[index] = true
    else
        if checked[index] then return true end
    end
    checked[index] = true
    return false
end

local function matchesFilter(filter, table)
    if type(filter) ~= "table" and filter ~= table then return false end
    for key, filterField in pairs(filter) do
        local value2 = table[key]
		if type(filterField) ~= "table" then
			if filterField ~= value2 then
				return false
			end
        else
            if not matchesFilter(filterField, value2) then
                return false
            end
        end
    end
    return true
end

local function checkAdj(filter, dig)
    local checkLeft = alreadyQueued(dig,"left") == false
    local checkForward = alreadyQueued(dig,"forward") == false
    local checkRight = alreadyQueued(dig,"right") == false
    local checkUp = alreadyQueued(dig,"up") == false
    local checkDown = alreadyQueued(dig,"down") == false
    if checkForward then
        local block, blockInfo = tex.inspect()
        if block then
            if blockInfo.name ~= "minecraft:bedrock" then
                if dig or (block and matchesFilter(filter, blockInfo)) then
                    tex.forward()
                    checkAdj(filter, (block and matchesFilter(filter, blockInfo)))
                    tex.back()
                end
            end
        end
    end
    if checkLeft then
        tex.left()
        local block, blockInfo = tex.inspect()
        if block then
            if blockInfo.name ~= "minecraft:bedrock" then
                if dig or (block and matchesFilter(filter, blockInfo)) then
                    tex.forward()
                    checkAdj(filter, (block and matchesFilter(filter, blockInfo)))
                    tex.back()
                end
            end
        end
        tex.right()
    end
    if checkRight then
        tex.right()
        local block, blockInfo = tex.inspect()
        if block then
            if blockInfo.name ~= "minecraft:bedrock" then
                if dig or (block and matchesFilter(filter, blockInfo)) then
                    tex.forward()
                    checkAdj(filter, (block and matchesFilter(filter, blockInfo)))
                    tex.back()
                end
            end
        end
        tex.left()
    end
    if checkUp then
        local block, blockInfo = tex.inspectUp()
        if block then
            if blockInfo.name ~= "minecraft:bedrock" then
                if dig or (block and matchesFilter(filter, blockInfo)) then
                    tex.up()
                    checkAdj(filter, (block and matchesFilter(filter, blockInfo)))
                    tex.down()
                end
            end
        end
    end
    if checkDown then
        local block, blockInfo = tex.inspectDown()
        if block then
            if blockInfo.name ~= "minecraft:bedrock" then
                if dig or (block and matchesFilter(filter, blockInfo)) then
                    tex.down()
                    checkAdj(filter, (block and matchesFilter(filter, blockInfo)))
                    tex.up()
                end
            end
        end
    end
end

local function collectVein(filter)
    checked = {}
    mined = {}
    checkAdj(filter)
end

local function extract(filter, distance)
    for _=1,distance do
        tex.forward(1, true)
        collectVein(filter)
    end
    for _=1,distance do
        tex.back()
    end
end

local filter = {
    tags={
        ["forge:ores"] = true
    }
}

extract(filter, 16)