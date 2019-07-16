
--Blocks chart
local id = {}
id.cover    = "minecraft:glass"
id.platform = "minecraft:cobblestone"
id.farmland = "minecraft:sand"
id.crop     = "minecraft:cactus"
id.harvester= "minecraft:fence"
id.light    = "minecraft:torch"

--Display
local w,h = term.getSize()
local _log = window.create(term.current(),1, 1, w, h-4)
local function clear()
	_log.setCursorPos(1,1)
	_log.clear()
	_log.redraw()
end
local function output(...)
	local x,y = term.getCursorPos()
	local old = term.redirect(_log)
	print(...)
	term.redirect(old)
	_log.redraw()
	term.setCursorPos(x,y)
end

--Safe ascent
local tooHigh = false
function tryUp()
	local r = {turtle.up()}
	tooHigh = not r[1] and r[2] == "Too high to move"
	return r
end

--Check inventory
local function newInv(...)
	local arg = {...}
	return {
--		[id.cover]    = arg[1] or 0, --80 Cover / stage
		[id.platform] = arg[2] or 0, --4 Platform / stage
		[id.farmland] = arg[3] or 0, --4 Farmland / stage
		[id.crop]  = arg[4] or 0, --4 Crop / stage
		[id.harvester]= arg[5] or 0, --2 Harvester / stage
		[id.light]    = arg[6] or 0, --1 Light level / stage
	}
end

function checkInventory()
	local count = newInv()
	output("Check inventory")
	for slot = 1, 16 do
		local data = turtle.getItemDetail(slot)
		if data and data.name and count[data.name] then
			count[data.name] = count[data.name] + data.count
			output("slot",slot..":",data.count,data.name)
		elseif  data and data.count > 0 then
			output("slot",slot..": useless", data.name,"-> drop()")
			turtle.select(slot)
			turtle.drop()
		else
			output("slot",slot..": empty")
		end
	end
	return count
end

function requiredItems(count)
	local itemPerStage = newInv(80,4,4,4,2,1) --items per stage
	local stages = math.huge
	for name, qty in pairs(count) do
		stages = math.min(stages, math.floor(qty / itemPerStage[name]))
	end
	output("Materials:",stages,"stages")
	return stages
end

function selectItem(name)
	output("Select item", name)
	for slot=1,16 do
		local data = turtle.getItemDetail(slot)
		if data and data.name == name then
			output("Found in slot:", slot)
			turtle.select(slot)
			return true
		end
	end
	return false
end

--Ascent
-- 4 step up without fence
function ascent()
	output("Ascent phase")
	
	--take place in the center
	output("Align to center")
	for i=1,3 do
		turtle.forward()
	end

	--step on first stage top layer
	output("VAlign top layer")
	repeat
		tryUp()
		if tooHigh then
			return false
		end
		local b, data = turtle.inspect()
	until b and data.name == id.harvester
	
	--reach last stage to build top layer
	output("Reach first stage to build")
	repeat
		for i=1,4 do
			tryUp()
			if tooHigh then
				return false
			end
		end
	until not turtle.detect()
	return true
end

--Build
function build(stagesToBuild)
	output("Starting build")
	
	--repositionning
	output("Repositionning - platform stage")
	for i=1,3 do
		turtle.down()
	end
	
	for i=1,stagesToBuild do
		--place platform
		output("Building platform")
		selectItem(id.platform)
		turtle.forward()
		turtle.turnLeft()
		turtle.place()
		turtle.turnLeft()
		turtle.turnLeft()
		turtle.place()
		turtle.turnRight()
		turtle.forward()
		turtle.forward()
		turtle.turnLeft()
		turtle.place()
		turtle.turnLeft()
		turtle.turnLeft()
		turtle.place()
		
		--place farmland
		output("Placing farmland")
		selectItem(id.farmland)
		tryUp()
		if tooHigh then
			return false
		end
		turtle.place()
		turtle.turnLeft()
		turtle.turnLeft()
		turtle.place()
		turtle.turnLeft()
		turtle.forward()
		turtle.forward()
		turtle.turnLeft()
		turtle.place()
		turtle.turnLeft()
		turtle.turnLeft()
		turtle.place()
		
		--place light
		output("Placing light source")
		selectItem(id.light)
		turtle.turnLeft()
		turtle.back()
		turtle.place()
		
		--place crop + harvester
		output("Plant crops and placing harvester")
		for i=1,2 do
			tryUp()
			if tooHigh then
				return false
			end
		end
		turtle.forward()
		turtle.turnLeft()
		turtle.forward()
		selectItem(id.crop)
		turtle.placeDown()
		turtle.back()
		turtle.back()
		turtle.placeDown()
		selectItem(id.harvester)
		turtle.place()
		turtle.turnLeft()
		turtle.forward()
		turtle.forward()
		selectItem(id.crop)
		turtle.placeDown()
		turtle.turnLeft()
		turtle.back()
		turtle.back()
		turtle.placeDown()
		selectItem(id.harvester)
		turtle.place()
		
		--reposition
		output("Reposition to center")
		turtle.turnLeft()
		turtle.forward()
		turtle.turnRight()
		turtle.forward()
		turtle.turnLeft()
		if stagesToBuild > i then
			output("Repositionning - platform stage")
			tryUp()
			if tooHigh then
				return false
			end
		end
	end
	return true
end

function descent()
	output("Descent")
	repeat
		local move = turtle.down()
	until not move
	output("Repositionning")
	for i=1,3 do
		turtle.back()
	end
end

--Main
repeat
	--Fuel level indicator
	local fuelPerCent = 100/turtle.getFuelLimit()
	local fuelIndicator = string.format(
		"Fuel: %s (%s%s)",
		turtle.getFuelLevel(),
		math.floor(turtle.getFuelLevel()*fuelPerCent),
		"%"
	)
	--Wait materials
	local stages
	local goForIt = false
	local itemPerStage = newInv(80,4,4,4,2,1) --items per stage
	repeat
		local inv = checkInventory()
		stages = requiredItems(inv)
		clear()
		output(fuelIndicator)
		for name, qty in pairs(inv) do
			output(qty, "/", itemPerStage[name], name)
		end
		output("Stages:", stages, (stages > 0) and "\nPress [Enter] to start" or "")
		repeat
			local e = {os.pullEvent()}
			if stages > 0 and e[1] == "key" then
				goForIt = (e[2] == keys.enter)
			end
		until e[1] == "turtle_inventory" or goForIt
	until stages > 0 and goForIt
	
	clear()
	output("start")
	sleep(2)
	
	if ascent() then
		build(stages)
	end
	descent()
	
	if tooHigh then
		output("Building reach highest altitude")
		local path = shell.getRunningProgram()
		shell.run("mv", path, fs.getDir(path).."/".."TooHigh_"..fs.getName(path))
		return
	end

	output("stop")
	sleep(2)
until false

--  GGGGG
-- G     G
-- G cFc G
-- G t   G
-- G cFc G
-- G     G
--  GGGGG 
--         __ 
-- G  F  G    
-- G c C G    
-- G StS G    
-- G C C G __ 
-- G  F  G
-- G c C G
-- G StS G
-- G C C G __
--