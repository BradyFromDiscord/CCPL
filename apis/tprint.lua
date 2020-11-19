local _p = settings.get("ccpl.path")
local tex = settings.get(_p.."ccpl.apis.tex")
local ux = settings.get(_p.."ccpl.apis.ux")

local function getIndex(array, value)
    for i, item in ipairs(array) do
        if item == value then
            return i
        end
    end
    return nil
end

local function extrude(data, currIndex)
    if data[currIndex] ~= 0 then
        tex.select(data[currIndex])
        tex.placeDown()
    end
end

local testHouse = {
    name="Test House",
    width=5,
    height=5,
    depth=5,
    data={},
    materials={}
}

local function handleBlock(houseObj, up)
    local func = (up and tex.inspectUp or tex.inspect)
    if tex.inspect() then
        local block = tex.inspect()
        local material = getIndex(houseObj.materials, block.name)
        if material then
            houseObj.materials[material].amount = houseObj.materials[material].amount + 1
            houseObj.data[i]=material
        else
            houseObj.materials[#houseObj.materials + 1] = { name=block.name, amount=1 }
            houseObj.data[i]=#houseObj.materials + 1
        end
    else
        houseObj.data[i] = 0
    end
end

local function scan(name, width, height, depth)
    local result = {
        name=name,
        width=width,
        height=height,
        depth=depth,
        data={},
        materials={}
    }
    local vPath = tex.createVPath(width, height, depth)
    local i = 1
    handleBlock(result)
    tex.forward(1,true)
    for instruction in vPath() do
        i = i + 1
        if instruction == "left" then
            tex.left()
            handleBlock(result)
            tex.forward(1,true)
            tex.left()
        elseif instruction == "right" then
            tex.right()
            handleBlock(result)
            tex.forward(1,true)
            tex.right()
        elseif instruction == "up" then
            tex.turnAround()
            tex.up(1,true)
        else
            tex.forward(1,true)
        end
    end
    return result
end

local function print(houseObj)
    ux.displaySlots(houseObj.materials)
    local vPath = tex.createVPath(houseObj.width,houseObj.height,houseObj.depth)
    i = 0
    for instruction in vPath() do
        i = i + 1
        if instruction == "left" then
            tex.left()
            tex.forward()
            tex.left()
        elseif instruction == "right" then
            tex.right()
            tex.forward()
            tex.right()
        elseif instruction == "up" then
            tex.turnAround()
            tex.up()
        else
            tex.forward()
        end
        extrude(houseObj.data, i)
    end
end

return {
    scan=scan,
    print=print
}