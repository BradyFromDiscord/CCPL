-- implements basic tprint API usage
local tex, tprint, ux, mobc = require("/ccpl")("tex", "tprint", "ux", "mobc")

local args = { ... }

local usage = {
    {"scan",{"width",{"height",{"depth","file-name"}}}},
    {"print","file-name"}
}
local start = os.clock()

if args[1] == "scan" then
    if #args ~= 5 then ux.displayUsage("3dprint",usage) do return end end

    for i=2,4 do
        args[i] = tonumber(args[i])
        if args[i] == nil then ux.displayUsage("3dprint",usage) do return end end
    end

    if string.find(args[5], ".mob",1,true) == nil then args[5] = args[5]..".mob" end

    if fs.exists(args[5]) then
        if not ux.confirm(args[5].." already exists! Would you like to replace it?",colors.red) then do return end end
    end

    local tcode = tprint.scan(tonumber(args[2]),tonumber(args[3]),tonumber(args[4]))
    local mob = mobc.tcodeToMob(tcode)
    local file = fs.open(args[5],"w")
    file.write(textutils.serialize(mob))
    file.close()

    tex.down(args[3]-1)
    local stop = os.clock()
    print("Scanned in "..(stop-start).." seconds!")
    print("You can print this structure by running \"3dprint print "..args[5].."\".")

elseif args[1] == "print" then
    if #args ~= 2 then ux.displayUsage("3dprint",usage) do return end end

    if fs.exists(args[2]..".mob") then args[2] = args[2]..".mob" end

    if not fs.exists(args[2]) then ux.displayUsage("3dprint",usage) do return end end

    local file = fs.open(args[2],"r")
    local mob = textutils.unserialize(file.readAll())
    file.close()
    local tcode = mobc.mobToTcode(mob)
    tprint.print(tcode)
    local stop = os.clock()
    print("Printed in "..(stop-start).." seconds!")
else
    ux.displayUsage("3dprint",usage)
end