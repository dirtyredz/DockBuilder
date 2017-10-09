
exsist, DockBuilderConfig = pcall(require, 'mods.DockBuilder.config.DockBuilderConfig')

--Default only, Make changes in mods/config.DockBuidlerConfig.lua

local defaultScripSstations = {
	equipmentDock = 50000000,		-- Equipment Dock
	turretFactory = 40000000,		-- Turret Factory
	researchStation = 50000000,	-- Research Station
	repairDock = 30000000,		-- Repair Dock
	shipyard = 50000000,			-- Shipyard
	fighterfactory = 50000000,	-- Fighter Factory
	resourcetrader = 40000000	-- Resource Trader
}

scriptstations = DockBuilderConfig.ScriptStations or defaultScripSstations

local productionsByButton = {}
local selectedProduction = {}

local warnWindow
local warnWindowLabel

--return array containing all factories
local Scriptables = {  }
if scriptstations["equipmentDock"] > 0 then
	Scriptables["equipmentDock"] = {
					name = "Equipment Dock"%_t,
					costs = scriptstations["equipmentDock"],
					scripts = {"data/scripts/entity/merchants/equipmentdock.lua",
							   "data/scripts/entity/merchants/turretmerchant.lua",
							   "data/scripts/entity/merchants/fightermerchant.lua"}
					}
end
if scriptstations["turretFactory"] > 0 then
	Scriptables["turretFactory"] = {
					name = "Turret Factory"%_t,
					costs = scriptstations["turretFactory"],
					scripts = {"data/scripts/entity/merchants/turretfactory.lua" }
					}
end
if scriptstations["researchStation"] > 0 then
	Scriptables["researchStation"] ={
					  name = "Research Station"%_t,
					  costs = scriptstations["researchStation"],
					  scripts = {"data/scripts/entity/merchants/researchstation.lua"}
					  }
end
if scriptstations["repairDock"] > 0 then
	Scriptables["repairDock"] =    {
					name = "Repair Dock"%_t,
					costs = scriptstations["repairDock"],
					scripts = {"data/scripts/entity/merchants/repairdock.lua"}
					}
end
if scriptstations["shipyard"] > 0 then
	Scriptables["shipyard"] =    {
					name = "Shipyard"%_t,
					costs = scriptstations["shipyard"],
					scripts = {"data/scripts/entity/merchants/shipyard.lua"}
					}
end
if scriptstations["fighterfactory"] > 0 then
	Scriptables["fighterfactory"] =    {
					name = "Fighter Factory"%_t,
					costs = scriptstations["fighterfactory"],
					scripts = {"data/scripts/entity/merchants/fighterfactory.lua"}
					}
end
if scriptstations["resourcetrader"] > 0 then
	Scriptables["resourcetrader"] =    {
					name = "Resource Depot"%_t,
					costs = scriptstations["resourcetrader"],
					scripts = {"data/scripts/entity/merchants/resourcetrader.lua"}
					}
end

-- this function gets called on creation of the entity the script is attached to, on client only
-- AFTER initialize above
-- create all required UI elements for the client side
function StationFounder.initUI()
    local res = getResolution()
    local size = vec2(650, 575)

    local menu = ScriptUI()
    local window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))

    window.caption = "Transform to Station"%_t
    window.showCloseButton = 1
    window.moveable = 1
    menu:registerWindow(window, "Found Station"%_t);

    -- create a tabbed window inside the main window
    local tabbedWindow = window:createTabbedWindow(Rect(vec2(10, 10), size - 10))

    -- create buy tab
    local buyTab0 = tabbedWindow:createTab("Basic"%_t, "data/textures/icons/purse.png", "Basic Factories"%_t)
    local buyTab1 = tabbedWindow:createTab("Low"%_t, "data/textures/icons/purse.png", "Low Tech Factories"%_t)
    local buyTab2 = tabbedWindow:createTab("Advanced"%_t, "data/textures/icons/purse.png", "Advanced Factories"%_t)
    local buyTab3 = tabbedWindow:createTab("High"%_t, "data/textures/icons/purse.png", "High Tech Factories"%_t)
	  local buyTab4 = tabbedWindow:createTab("Special"%_t, "data/textures/icons/hammer-nails.png", "Shops"%_t)

    StationFounder.buildGui({0}, buyTab0)
    StationFounder.buildGui({1, 2, 3}, buyTab1)
    StationFounder.buildGui({4, 5, 6}, buyTab2)
    StationFounder.buildGui({7, 8, 9}, buyTab3)

	  StationFounder.buildSpecialGui(buyTab4)
    local temp = Scriptables

    -- warn box

    -- warn box
    local size = vec2(550, 230)
    warnWindow = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
    warnWindow.caption = "Confirm Transformation"%_t
    warnWindow.showCloseButton = 1
    warnWindow.moveable = 1
    warnWindow.visible = false

    local hsplit = UIHorizontalSplitter(Rect(vec2(), warnWindow.size), 10, 10, 0.5)
    hsplit.bottomSize = 40

    warnWindow:createFrame(hsplit.top)

    local ihsplit = UIHorizontalSplitter(hsplit.top, 10, 10, 0.5)
    ihsplit.topSize = 20

    local label = warnWindow:createLabel(ihsplit.top.lower, "Warning"%_t, 16)
    label.size = ihsplit.top.size
    label.bold = true
    label.color = ColorRGB(0.8, 0.8, 0)
    label:setTopAligned();

    warnWindowLabel = warnWindow:createLabel(ihsplit.bottom.lower, "Text"%_t, 14)
    warnWindowLabel.size = ihsplit.bottom.size
    warnWindowLabel:setTopAligned();


    local vsplit = UIVerticalSplitter(hsplit.bottom, 10, 0, 0.5)
    warnWindow:createButton(vsplit.left, "OK"%_t, "onConfirmTransformationButtonPress")
    warnWindow:createButton(vsplit.right, "Cancel"%_t, "onCancelTransformationButtonPress")

end

function StationFounder.buildGui(levels, tab)

    -- make levels a table with key == value
    local l = {}
    for _, v in pairs(levels) do
        l[v] = v
    end
    levels = l

    -- create background
    local frame = tab:createScrollFrame(Rect(vec2(), tab.size))
    frame.scrollSpeed = 40
    frame.paddingBottom = 17

    local usedProductions = {}
    local possibleProductions = {}

    for _, productions in pairs(productionsByGood) do

        for index, production in pairs(productions) do

            -- mines shouldn't be built just like that, they need asteroids
            if not string.match(production.factory, "Mine") then

                -- read data from production
                local result = goods[production.results[1].name];

                -- only insert if the level is in the list
                if levels[result.level] ~= nil and not usedProductions[production.index] then
                    usedProductions[production.index] = true
                    --Dirtyredz & Laserzwei
                    --table.insert(possibleProductions, {production=production, index=index})
                    table.insert(possibleProductions, production)
                end
            end
        end
    end

    --Dirtyredz & Laserzwei
    local comp = function(a, b)
        local nameA = a.factory
        if a.fixedName == false then
            nameA = a.results[1].name%_t .. " " .. nameA%_t
        end

        local nameB = b.factory
        if b.fixedName == false then
            nameB = b.results[1].name%_t .. " " .. nameB%_t
        end

        return nameA < nameB
    end

    table.sort(possibleProductions, comp)

    local count = 0
    for _, p in StationFounder.spairs(possibleProductions, function(t,a,b) return getTranslatedFactoryName(possibleProductions[b]) > getTranslatedFactoryName(possibleProductions[a]) end) do

        --Dirtyredz & Laserzwei
        --local production = p.production
        --local index = p.index
        local production = p
        local result = goods[production.results[1].name];
        local factoryName = getTranslatedFactoryName(production)

        local padding = 10
        local height = 30
        local width = frame.size.x - padding * 4

        local lower = vec2(padding, padding + ((height + padding) * count))
        local upper = lower + vec2(width, height)

        local rect = Rect(lower, upper)

        local vsplit = UIVerticalSplitter(rect, 10, 0, 0.8)
        vsplit.rightSize = 100

        local button = frame:createButton(vsplit.right, "Transform"%_t, "onFoundFactoryButtonPress")
        button.textSize = 16
        button.bold = false

        frame:createFrame(vsplit.left)

        vsplit = UIVerticalSplitter(vsplit.left, 10, 7, 0.7)

        local label = frame:createLabel(vsplit.left.lower, factoryName, 14)
        label.size = vec2(vsplit.left.size.x, vsplit.left.size.y)
        label:setLeftAligned()

        local tooltip = "Produces:\n"%_t
        for i, result in pairs(production.results) do
            if i > 1 then tooltip = tooltip .. "\n" end
            tooltip = tooltip .. " - " .. result.name%_t
        end


        local first = 1
        for _, i in pairs(production.ingredients) do
            if first == 1 then
                tooltip = tooltip .. "\n\n" .. "Requires:"%_t
                first = 0
            end
            tooltip = tooltip .. "\n - " .. i.name%_t
        end
        label.tooltip = tooltip

        local costs = StationFounder.getFactoryCost(production)

        local label = frame:createLabel(vsplit.right.lower, createMonetaryString(costs) .. " Cr"%_t, 14)
        label.size = vec2(vsplit.right.size.x, vsplit.right.size.y)
        label:setRightAligned()

        --Dirtyredz & Laserzwei
        --productionsByButton[button.index] = {goodName = result.name, factory=factoryName, index = index, production = production}
        productionsByButton[button.index] = {goodName = result.name, factory=factoryName, production = production, index = p.index}
        count = count + 1

    end

end

function StationFounder.spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function StationFounder.buildSpecialGui(tab)

    -- create background
    local frame = tab:createScrollFrame(Rect(vec2(), tab.size))
    frame.scrollSpeed = 40
    frame.paddingBottom = 17

    local possibleBuildings = Scriptables

    local count = 0

    for specialIndex, p in pairs(possibleBuildings) do

        local factoryName = p.name

        local padding = 10
        local height = 30
        local width = frame.size.x - padding * 4

        local lower = vec2(padding, padding + ((height + padding) * count))
        local upper = lower + vec2(width, height)

        local rect = Rect(lower, upper)

        local vsplit = UIVerticalSplitter(rect, 10, 0, 0.8)
        vsplit.rightSize = 100

        local button = frame:createButton(vsplit.right, "Transform"%_t, "onFoundFactoryButtonPress")
        button.textSize = 16
        button.bold = false

        frame:createFrame(vsplit.left)

        vsplit = UIVerticalSplitter(vsplit.left, 10, 7, 0.7)

        local label = frame:createLabel(vsplit.left.lower, factoryName, 14)
        label.size = vec2(vsplit.left.size.x, vsplit.left.size.y)
        label:setLeftAligned()

        --local tooltip = p.name --replace w/ actual description later

        label.tooltip = p.name--tooltip

        local costs = p.costs

        local label = frame:createLabel(vsplit.right.lower, createMonetaryString(costs) .. " Cr"%_t, 14)
        label.size = vec2(vsplit.right.size.x, vsplit.right.size.y)
        label:setRightAligned()

        --Giving it a different type from name so that it doesn't go into the function below.
        productionsByButton[button.index] = {specialName=factoryName, index = specialIndex, buildType = "special"}

        count = count + 1

    end

end

function StationFounder.onFoundFactoryButtonPress(button)
    selectedProduction = productionsByButton[button.index]

    warnWindowLabel.caption = "This action is irreversible."%_t .."\n\n" ..
  --"You're about to transform your ship into a ${factory}.\n"%_t % {factory = getTranslatedFactoryName(selectedProduction.production)} ..
		"You're about to transform your ship into a ${factory}.\n"%_t % {factory = selectedProduction.specialName or getTranslatedFactoryName(selectedProduction.production)} ..
        "Your ship will become immobile and, if required, will receive production extensions.\n"%_t ..
        "Due to a systems change all turrets will be removed from your station."%_t
    warnWindowLabel.fontSize = 14

    warnWindow:show()
end

function StationFounder.onConfirmTransformationButtonPress(button)
    --invokeServerFunction("foundFactory", selectedProduction.goodName, selectedProduction.index)
	if selectedProduction.buildType == "special" then
        invokeServerFunction("foundSpecial", selectedProduction.index)
    else
        invokeServerFunction("foundFactory", selectedProduction.goodName, selectedProduction.index)
    end
end

function StationFounder.onCancelTransformationButtonPress(button)
    warnWindow:hide()
end

function StationFounder.foundFactory(goodName, productionIndex)

    local buyer, ship, player = checkEntityInteractionPermissions(Entity(), AlliancePrivilege.FoundStations)
    if not buyer then return end

    --Dirtyredz & Laserzwei
    --local production = productionsByGood[goodName][productionIndex]
    local production = productions[productionIndex]

    if production == nil then
        player:sendChatMessage("Server"%_t, 1, "The production line you chose doesn't exist."%_t)
        return
    end

    -- check if player has enough money
    local cost = StationFounder.getFactoryCost(production)

    local canPay, msg, args = buyer:canPay(cost)
    if not canPay then
        player:sendChatMessage("Station Founder"%_t, 1, msg, unpack(args))
        return
    end

    local station = StationFounder.transformToStation()
    if not station then return end

    buyer:payMoney(cost)

    -- make a factory
    station:addScript("data/scripts/entity/merchants/factory.lua", "nothing")
    station:invokeFunction("factory", "setProduction", production, 1)

    -- remove all cargo that might have been added by the factory script
    for cargo, amount in pairs(station:getCargos()) do
        station:removeCargo(cargo, amount)
    end

    -- insert cargo of the ship that founded the station
    for good, amount in pairs(ship:getCargos()) do
        station:addCargo(good, amount)
	end
  --Complex Stations
  station:addScript("data/scripts/entity/complexManager.lua")
end

	--Copypasta because i wouldn't want to modify the other one too much.
function StationFounder.foundSpecial(scriptableIndex)

    local scriptable  = Scriptables[scriptableIndex]
    --print(scriptable.name)
    local buyer, ship, player = checkEntityInteractionPermissions(Entity(), AlliancePrivilege.FoundStations)
    if player.index ~= callingPlayer then return end
    if not buyer then return end

    if scriptable == nil then
        player:sendChatMessage("Server"%_t, 1, "The scriptable/dock you chose doesn't exist."%_t)
        return
    end

    --check if player has enough money
    local cost = scriptable.costs --getFactoryCost(production)
    local shipVolume = ship.volume

    local canPay, msg, args = buyer:canPay(cost)
    if not canPay then
        player:sendChatMessage("Station Founder"%_t, 1, msg, unpack(args))
        return
    end

    --shipvolume is volume that you see ingame/1000
    if shipVolume < 200 then --if the volume is less than 500k
        player:sendChatMessage("Station Founder"%_t, 1, "Your ship needs to have 200,000 or more volume to convert!")
        return
    end

    --debugging stuff
    for _,scr in pairs(scriptable.scripts) do
        print(scr)
    end

    local station = StationFounder.transformToStation()

    if not station then return end

    --Some stations don't have a default title (research stations) so we name them here just in case.
    station.title = scriptable.name
    buyer:payMoney(cost)

    -- make a special station, add all the scripts it requires
    for _,scr in pairs(scriptable.scripts) do
        station:addScript(scr)
    end

    -- remove all cargo that might have been added by the factory script
    for cargo, amount in pairs(station:getCargos()) do
        station:removeCargo(cargo, amount)
    end


    -- insert cargo of the ship that founded the station
    for good, amount in pairs(ship:getCargos()) do
        station:addCargo(good, amount)
    end
end

function StationFounder.transformToStation()

    --local ship = Entity()
    --local player = Player(callingPlayer)
    local buyer, ship, player, alliance = checkEntityInteractionPermissions(Entity(), AlliancePrivilege.FoundStations)

    -- transform ship into station
    -- has to be at least 2 km from the nearest station
    local sector = Sector()

    local stations = {sector:getEntitiesByType(EntityType.Station)}
    local ownSphere = ship:getBoundingSphere()
    local minDist = 300
    local tooNear

    for _, station in pairs(stations) do
        local sphere = station:getBoundingSphere()

        local d = distance(sphere.center, ownSphere.center) - sphere.radius - ownSphere.radius
        if d < minDist then
            tooNear = true
            break
        end
    end

    if tooNear then
        player:sendChatMessage("Server"%_t, 1, "You're too close to another station."%_t)
        return
    end

    -- create the station
    -- get plan of ship
    local plan = ship:getPlan()
    local crew = ship.crew

    -- create station
    --[[local desc = StationDescriptor()
    desc.factionIndex = ship.factionIndex
    desc:setPlan(plan)
    desc.position = ship.position
    desc:addScript("data/scripts/entity/crewboard.lua")
    desc.name = ship.name

    ship.name = ""

    local station = Sector():createEntity(desc)]]

    local station = sector:createStation(buyer, plan, ship.position, "data/scripts/entity/crewboard.lua")

    AddDefaultStationScripts(station)

    -- this will delete the ship and deactivate the collision detection so the ship doesn't interfere with the new station
    ship:setPlan(BlockPlan())

    -- assign all values of the ship
    -- crew
    station.crew = crew
    station.shieldDurability = ship.shieldDurability

    -- transfer insurance
    local ret, values = ship:invokeFunction("insurance.lua", "getValues")
    if ret == 0 then
        ship:removeScript("insurance.lua")
        station:addScriptOnce("insurance.lua")
        station:invokeFunction("insurance.lua", "restore", values)
    end

    return station
end

-- this function gets called every time the window is closed on the client
function StationFounder.onCloseWindow()
    warnWindow:hide()
end
