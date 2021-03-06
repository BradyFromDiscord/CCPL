-- implements basic farming API usage
local farming, ux = require("/ccpl")("farming","ux")

local usage = {
    {"create",{"x","y"}},
    {"harvest",{"x","y"}}
}

local args = { ... }
args[2] = tonumber(args[2])
args[3] = tonumber(args[3])

-- error checking
if type(args[2]) ~= "number" or type(args[3]) ~= "number" then
    ux.displayUsage("farm",usage)
    do return end
end
if args[2] < 1 or args[3] < 1 then
    ux.displayUsage("farm",usage)
    do return end
end

if args[1] == "create" then
    farming.createFarm(args[2], args[3])
elseif args[1] == "harvest" then
    farming.farm(args[2], args[3])
else
    ux.displayUsage("farm",usage)
end