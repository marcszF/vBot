setDefaultTab("Tools")

-- securing storage namespace
local panelName = "extras"
if not storage[panelName] then
  storage[panelName] = {}
end
local settings = storage[panelName]
rootWidget = rootWidget or g_ui.getRootWidget()
local addIcon = addIcon or (modules.game_bot and modules.game_bot.addIcon)
local toolsPanel = modules.game_bot and modules.game_bot.contentsPanel and (modules.game_bot.contentsPanel:getChildById("Tools") or modules.game_bot.contentsPanel)
local checkBoxes = {}
local iconWidgets = {}

-- basic elements
extrasWindow = UI.createWidget('ExtrasWindow', toolsPanel or rootWidget)
extrasWindow.onGeometryChange = function(widget, old, new)
  if old.height == 0 then return end
  settings.height = new.height
end
extrasWindow:setHeight(settings.height or 360)

-- available options for dest param
local rightPanel = extrasWindow.content.right
local leftPanel = extrasWindow.content.left

-- objects made by Kondrah - taken from creature editor, minor changes to adapt
local addCheckBox = function(id, title, defaultValue, dest, tooltip)
  local widget = UI.createWidget('ExtrasCheckBox', dest)
  widget.onClick = function()
    widget:setOn(not widget:isOn())
    settings[id] = widget:isOn()
    if iconWidgets[id] then
      iconWidgets[id]:setOn(widget:isOn())
    end
    if id == "checkPlayer" then
      local label = rootWidget.newHealer.targetSettings.vocations.title
      if not widget:isOn() then
        label:setColor("#d9321f")
        label:setTooltip("! WARNING ! \nTurn on check players in extras to use this feature!")
      else
          label:setColor("#dfdfdf")
          label:setTooltip("")
      end
    end
  end
  widget:setText(title)
  widget:setTooltip(tooltip)
  if settings[id] == nil then
    widget:setOn(defaultValue)
  else
    widget:setOn(settings[id])
  end
  settings[id] = widget:isOn()
  checkBoxes[id] = widget
  return widget
end

local function addToggleIcon(id, data)
  if not addIcon then return end
  local icon = addIcon(id, data, function(widget, isOn)
    settings[id] = isOn
    if checkBoxes[id] then
      checkBoxes[id]:setOn(isOn)
    end
  end)
  if icon then
    iconWidgets[id] = icon
    icon:setOn(not not settings[id])
  end
  return icon
end

local function setIconItem(iconId, itemId, fallback)
  local icon = iconWidgets[iconId]
  if not icon then return end
  local resolved = tonumber(itemId)
  if resolved == nil then
    resolved = tonumber(fallback)
  end
  if not resolved or resolved <= 0 then return end
  if icon.setItemId then
    icon:setItemId(resolved)
  elseif icon.item and icon.item.setItemId then
    icon.item:setItemId(resolved)
  end
end

local addItem = function(id, title, defaultItem, dest, tooltip, onChange)
  local widget = UI.createWidget('ExtrasItem', dest)
  widget.text:setText(title)
  widget.text:setTooltip(tooltip)
  widget.item:setTooltip(tooltip)
  widget.item:setItemId(settings[id] or defaultItem)
  widget.item.onItemChange = function(widget)
    settings[id] = widget:getItemId()
    if onChange then
      onChange(settings[id], widget)
    end
  end
  settings[id] = settings[id] or defaultItem
  if onChange then
    onChange(settings[id], widget.item)
  end
  return widget
end

local addTextEdit = function(id, title, defaultValue, dest, tooltip, onChange)
  local widget = UI.createWidget('ExtrasTextEdit', dest)
  widget.text:setText(title)
  widget.textEdit:setText(settings[id] or defaultValue or "")
  widget.text:setTooltip(tooltip)
  widget.textEdit.onTextChange = function(widget,text)
    settings[id] = text
    if onChange then
      onChange(text, widget)
    end
  end
  settings[id] = settings[id] or defaultValue or ""
  if onChange then
    onChange(settings[id], widget.textEdit)
  end
  return widget
end

local addScrollBar = function(id, title, min, max, defaultValue, dest, tooltip)
  local widget = UI.createWidget('ExtrasScrollBar', dest)
  widget.text:setTooltip(tooltip)
  widget.scroll.onValueChange = function(scroll, value)
    widget.text:setText(title .. ": " .. value)
    if value == 0 then
      value = 1
    end
    settings[id] = value
  end
  widget.scroll:setRange(min, max)
  widget.scroll:setTooltip(tooltip)
  if max-min > 1000 then
    widget.scroll:setStep(100)
  elseif max-min > 100 then
    widget.scroll:setStep(10)
  end
  widget.scroll:setValue(settings[id] or defaultValue)
  widget.scroll.onValueChange(widget.scroll, widget.scroll:getValue())
end

---- to maintain order, add options right after another:
--- add object
--- add variables for function (optional)
--- add callback (optional)
--- optionals should be addionaly sandboxed (if true then end)

addItem("rope", "Rope Item", 9596, leftPanel, "This item will be used in various bot related scripts as default rope item.")
addItem("shovel", "Shovel Item", 9596, leftPanel, "This item will be used in various bot related scripts as default shovel item.")
addItem("machete", "Machete Item", 9596, leftPanel, "This item will be used in various bot related scripts as default machete item.")
addItem("scythe", "Scythe Item", 9596, leftPanel, "This item will be used in various bot related scripts as default scythe item.")
addCheckBox("pathfinding", "CaveBot Pathfinding", true, leftPanel, "Cavebot will automatically search for first reachable waypoint after missing 10 goto's.")
addScrollBar("talkDelay", "Global NPC Talk Delay", 0, 2000, 1000, leftPanel, "Breaks between each talk action in cavebot (time in miliseconds).")
addScrollBar("looting", "Max Loot Distance", 0, 50, 40, leftPanel, "Every loot corpse futher than set distance (in sqm) will be ignored and forgotten.")
addScrollBar("lootDelay", "Loot Delay", 0, 1000, 200, leftPanel, "Wait time for loot container to open. Lower value means faster looting. \n WARNING if you are having looting issues(e.g. container is locked in closing/opnening), increase this value.")
addScrollBar("huntRoutes", "Hunting Rounds Limit", 0, 300, 50, leftPanel, "Round limit for supply check, if character already made more rounds than set, on next supply check will return to city.")
addScrollBar("killUnder", "Kill monsters below", 0, 100, 1, leftPanel, "Force TargetBot to kill added creatures when they are below set percentage of health - will ignore all other TargetBot settings.")
addScrollBar("gotoMaxDistance", "Max GoTo Distance", 0, 127, 30, leftPanel, "Maximum distance to next goto waypoint for the bot to try to reach.")
addCheckBox("lootLast", "Start loot from last corpse", true, leftPanel, "Looting sequence will be reverted and bot will start looting newest bodies.")
addCheckBox("joinBot", "Join TargetBot and CaveBot", false, leftPanel, "Cave and Target tabs will be joined into one.")
addCheckBox("reachable", "Target only pathable mobs", false, leftPanel, "Ignore monsters that can't be reached.")

addCheckBox("title", "Custom Window Title", true, rightPanel, "Personalize OTCv8 window name according to character specific.")
if true then
  local vocText = ""

  if voc() == 1 or voc() == 11 then
      vocText = "- EK"
  elseif voc() == 2 or voc() == 12 then
      vocText = "- RP"
  elseif voc() == 3 or voc() == 13 then
      vocText = "- MS"
  elseif voc() == 4 or voc() == 14 then
      vocText = "- ED"
  end

  macro(5000, function()
    if settings.title then
      if hppercent() > 0 then
          g_window.setTitle("Tibia - " .. name() .. " - " .. lvl() .. "lvl " .. vocText)
      else
          g_window.setTitle("Tibia - " .. name() .. " - DEAD")
      end
    else
      g_window.setTitle("Tibia - " .. name())
    end
  end)
end

addCheckBox("separatePm", "Open PM's in new Window", false, rightPanel, "PM's will be automatically opened in new tab after receiving one.")
if true then
  onTalk(function(name, level, mode, text, channelId, pos)
    if mode == 4 and settings.separatePm then
        local g_console = modules.game_console
        local privateTab = g_console.getTab(name)
        if privateTab == nil then
            privateTab = g_console.addTab(name, true)
            g_console.addPrivateText(g_console.applyMessagePrefixies(name, level, text), g_console.SpeakTypesSettings['private'], name, false, name)
        end
        return
    end
  end)
end

addTextEdit("useAll", "Use All Hotkey", "space", rightPanel, "Set hotkey for universal actions - rope, shovel, scythe, use, open doors")
if true then
  local useId = { 34847, 1764, 21051, 30823, 6264, 5282, 20453, 20454, 20474, 11708, 11705, 
                  6257, 6256, 2772, 27260, 2773, 1632, 1633, 1948, 435, 6252, 6253, 5007, 4911, 
                  1629, 1630, 5108, 5107, 5281, 1968, 435, 1948, 5542, 31116, 31120, 30742, 31115, 
                  31118, 20474, 5737, 5736, 5734, 5733, 31202, 31228, 31199, 31200, 33262, 30824, 
                  5125, 5126, 5116, 5117, 8257, 8258, 8255, 8256, 5120, 30777, 30776, 23873, 23877,
                  5736, 6264, 31262, 31130, 31129, 6250, 6249, 5122, 30049, 7131, 7132, 7727 }
  local shovelId = { 606, 593, 867, 608 }
  local ropeId = { 17238, 12202, 12935, 386, 421, 21966, 14238 }
  local macheteId = { 2130, 3696 }
  local scytheId = { 3653 }

  setDefaultTab("Tools")
  -- script
  if settings.useAll and settings.useAll:len() > 0 then
    hotkey(settings.useAll, function()
        if not (modules.game_walking and modules.game_walking.wsadWalking) then return end
        for _, tile in pairs(g_map.getTiles(posz())) do
            if distanceFromPlayer(tile:getPosition()) < 2 then
                for _, item in pairs(tile:getItems()) do
                    -- use
                    if table.find(useId, item:getId()) then
                        use(item)
                        return
                    elseif table.find(shovelId, item:getId()) then
                        useWith(settings.shovel, item)
                        return
                    elseif table.find(ropeId, item:getId()) then
                        useWith(settings.rope, item) 
                        return
                    elseif table.find(macheteId, item:getId()) then
                        useWith(settings.machete, item)
                        return
                    elseif table.find(scytheId, item:getId()) then
                        useWith(settings.scythe, item)
                        return
                    end
                end
            end
        end
    end)
  end
end


addCheckBox("timers", "MW & WG Timers", true, rightPanel, "Show times for Magic Walls and Wild Growths.")
if true then
  local activeTimers = {}

  onAddThing(function(tile, thing)
    if not settings.timers then return end
    if not thing:isItem() then
      return
    end
    local timer = 0
    if thing:getId() == 2129 then -- mwall id
      timer = 20000 -- mwall time
    elseif thing:getId() == 2130 then -- wg id
      timer = 45000 -- wg time
    else
      return
    end

    local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
    if not activeTimers[pos] or activeTimers[pos] < now then    
      activeTimers[pos] = now + timer
    end
    tile:setTimer(activeTimers[pos] - now)
  end)

  onRemoveThing(function(tile, thing)
    if not settings.timers then return end
    if not thing:isItem() then
      return
    end
    if (thing:getId() == 2129 or thing:getId() == 2130) and tile:getGround() then
      local pos = tile:getPosition().x .. "," .. tile:getPosition().y .. "," .. tile:getPosition().z
      activeTimers[pos] = nil
      tile:setTimer(0)
    end  
  end)
end


addCheckBox("antiKick", "Anti - Kick", true, rightPanel, "Turn every 10 minutes to prevent kick.")
if true then
  macro(600*1000, function()
    if not settings.antiKick then return end
    local dir = player:getDirection()
    turn((dir + 1) % 4)
    schedule(50, function() turn(dir) end)
  end)
end


addCheckBox("stake", "Skin Monsters", false, leftPanel, "Automatically skin & stake corpses when cavebot is enabled")
if true then
  local knifeBodies = {4286, 4272, 4173, 4011, 4025, 4047, 4052, 4057, 4062, 4112, 4212, 4321, 4324, 4327, 10352, 10356, 10360, 10364} 
  local stakeBodies = {4097, 4137, 8738, 18958}
  local fishingBodies = {9582}
  macro(500, function()
      if not CaveBot.isOn() or not settings.stake then return end
      for i, tile in ipairs(g_map.getTiles(posz())) do
        local item = tile:getTopThing()
        if item and item:isContainer() then
          if table.find(knifeBodies, item:getId()) and findItem(5908) then
              CaveBot.delay(550)
              useWith(5908, item)
              return
          end
          if table.find(stakeBodies, item:getId()) and findItem(5942) then
              CaveBot.delay(550)
              useWith(5942, item)
              return
          end
          if table.find(fishingBodies, item:getId()) and findItem(3483) then
              CaveBot.delay(550)
              useWith(3483, item)
              return
          end
        end
      end
  end)
end


addCheckBox("oberon", "Auto Reply Oberon", true, rightPanel, "Auto reply to Grand Master Oberon talk minigame.")
if true then
  onTalk(function(name, level, mode, text, channelId, pos)
    if not settings.oberon then return end
    if mode == 34 then
        if string.find(text, "world will suffer for") then
            say("Are you ever going to fight or do you prefer talking?")
        elseif string.find(text, "feet when they see me") then
            say("Even before they smell your breath?")
        elseif string.find(text, "from this plane") then
            say("Too bad you barely exist at all!") 
        elseif string.find(text, "ESDO LO") then
            say("SEHWO ASIMO, TOLIDO ESD") 
        elseif string.find(text, "will soon rule this world") then
            say("Excuse me but I still do not get the message!") 
        elseif string.find(text, "honourable and formidable") then
            say("Then why are we fighting alone right now?") 
        elseif string.find(text, "appear like a worm") then
            say("How appropriate, you look like something worms already got the better of!") 
        elseif string.find(text, "will be the end of mortal") then
            say("Then let me show you the concept of mortality before it!") 
        elseif string.find(text, "virtues of chivalry") then
            say("Dare strike up a Minnesang and you will receive your last accolade!") 
        end
    end
  end)
end


addCheckBox("autoOpenDoors", "Auto Open Doors", true, rightPanel, "Open doors when trying to step on them.")
if true then
  local doorsIds = { 5007, 8265, 1629, 1632, 5129, 6252, 6249, 7715, 7712, 7714, 
                     7719, 6256, 1669, 1672, 5125, 5115, 5124, 17701, 17710, 1642, 
                     6260, 5107, 4912, 6251, 5291, 1683, 1696, 1692, 5006, 2179, 5116, 
                     1632, 11705, 30772, 30774, 6248, 5735, 5732, 5120, 23873, 5736,
                     6264, 5122, 30049, 30042, 7727 }

  function checkForDoors(pos)
    local tile = g_map.getTile(pos)
    if tile then
      local useThing = tile:getTopUseThing()
      if useThing and table.find(doorsIds, useThing:getId()) then
        g_game.use(useThing)
      end
    end
  end

  onKeyPress(function(keys)
    local wsadWalking = modules.game_walking and modules.game_walking.wsadWalking
    if not settings.autoOpenDoors then return end
    local pos = player:getPosition()
    if keys == 'Up' or (wsadWalking and keys == 'W') then
      pos.y = pos.y - 1
    elseif keys == 'Down' or (wsadWalking and keys == 'S') then
      pos.y = pos.y + 1
    elseif keys == 'Left' or (wsadWalking and keys == 'A') then
      pos.x = pos.x - 1
    elseif keys == 'Right' or (wsadWalking and keys == 'D') then
      pos.x = pos.x + 1
    elseif wsadWalking and keys == "Q" then
      pos.y = pos.y - 1
      pos.x = pos.x - 1
    elseif wsadWalking and keys == "E" then
      pos.y = pos.y - 1
      pos.x = pos.x + 1
    elseif wsadWalking and keys == "Z" then
      pos.y = pos.y + 1
      pos.x = pos.x - 1
    elseif wsadWalking and keys == "C" then
      pos.y = pos.y + 1
      pos.x = pos.x + 1
    end
    checkForDoors(pos)
  end)
end


addCheckBox("bless", "Buy bless at login", true, rightPanel, "Say !bless at login.")
if true then
  local blessed = false
  onTextMessage(function(mode,text) 
    if not settings.bless then return end
    
    text = text:lower()

    if text == "you already have all blessings." then
      blessed = true
    end
  end)
  if settings.bless then
    if player:getBlessings() == 0 then
      say("!bless")
      schedule(2000, function() 
          if g_game.getClientVersion() > 1000 then
            if not blessed and player:getBlessings() == 0 then
                warn("!! Blessings not bought !!")
            end
          end
      end)
    end
  end
end


addCheckBox("reUse", "Keep Crosshair", false, rightPanel, "Keep crosshair after using with item")
if true then
  local excluded = {268, 237, 238, 23373, 266, 236, 239, 7643, 23375, 7642, 23374, 5908, 5942} 

  onUseWith(function(pos, itemId, target, subType)
    if settings.reUse and not table.find(excluded, itemId) then
      schedule(50, function()
        item = findItem(itemId)
        if item then
          modules.game_interface.startUseWith(item)
        end
      end)
    end
  end)
end


addCheckBox("suppliesControl", "TargetBot off if low supply", false, leftPanel, "Turn off TargetBot if either one of supply amount is below 50% of minimum.")
if true then
  macro(500, function()
    if not settings.suppliesControl then return end
    if TargetBot.isOff() then return end
    if CaveBot.isOff() then return end
    if type(hasSupplies()) == 'table' then
        TargetBot.setOff()
    end
  end)
end

addCheckBox("holdMwall", "Hold MW/WG", true, rightPanel, "Mark tiles with below hotkeys to automatically use Magic Wall or Wild Growth")
addTextEdit("holdMwHot", "Magic Wall Hotkey: ", "F5", rightPanel)
addTextEdit("holdWgHot", "Wild Growth Hotkey: ", "F6", rightPanel)
if true then

  local hold = 0
  local mwHot
  local wgHot

  local candidates = {}
  local m = macro(20, function()
    mwHot = settings.holdMwHot
    wgHot = settings.holdWgHot
    
    if not settings.holdMwall then return end
      if #candidates == 0 then return end

      for i, pos in pairs(candidates) do
        local tile = g_map.getTile(pos)
        if tile then
          if tile:getText():len() == 0 then 
            table.remove(candidates, i)
          end
          local rune = tile:getText() == "HOLD MW" and 3180 or tile:getText() == "HOLD WG" and 3156
          if tile:canShoot() and not isInPz() and tile:isWalkable() and tile:getTopUseThing():getId() ~= 2130 then
            if math.abs(player:getPosition().x-tile:getPosition().x) < 8 and math.abs(player:getPosition().y-tile:getPosition().y) < 6 then
              return useWith(rune, tile:getTopUseThing())
            end
          end
        end
      end
  end)

  onRemoveThing(function(tile, thing)
    if not settings.holdMwall then return end
      if thing:getId() ~= 2129 then return end
      if tile:getText():find("HOLD") then
          table.insert(candidates, tile:getPosition())
          local rune = tile:getText() == "HOLD MW" and 3180 or tile:getText() == "HOLD WG" and 3156
          if math.abs(player:getPosition().x-tile:getPosition().x) < 8 and math.abs(player:getPosition().y-tile:getPosition().y) < 6 then
            return useWith(rune, tile:getTopUseThing())
          end
      end
  end)

  onAddThing(function(tile, thing)
    if not settings.holdMwall then return end
      if m.isOff() then return end
      if thing:getId() ~= 2129 then return end
      if tile:getText():len() > 0 then
          table.remove(candidates, table.find(candidates,tile))
      end
  end)

  onKeyDown(function(keys)
    local wsadWalking = modules.game_walking and modules.game_walking.wsadWalking
    if not wsadWalking then return end
    if not settings.holdMwall then return end
    if m.isOff() then return end
    if keys ~= mwHot and keys ~= wgHot then return end
    hold = now

    local tile = getTileUnderCursor()
    if not tile then return end

    if tile:getText():len() > 0 then
        tile:setText("")
    else
        if keys == mwHot then
            tile:setText("HOLD MW")
        else
            tile:setText("HOLD WG")
        end
        table.insert(candidates, tile:getPosition())
    end
  end)

  onKeyPress(function(keys)
    local wsadWalking = modules.game_walking and modules.game_walking.wsadWalking
    if not wsadWalking then return end
    if not settings.holdMwall then return end
    if m.isOff() then return end
    if keys ~= mwHot and keys ~= wgHot then return end

    if (hold - now) < -1000 then
      candidates = {}
      for i, tile in ipairs(g_map.getTiles(posz())) do
        local text = tile:getText()
        if text:find("HOLD") then
          tile:setText("")
        end
      end
    end
  end)
end

addCheckBox("checkPlayer", "Check Players", true, rightPanel, "Auto look on players and mark level and vocation on character model")
if true then
  local found
  local function checkPlayers()
    for i, spec in ipairs(getSpectators()) do
      if spec:isPlayer() and spec:getText() == "" and spec:getPosition().z == posz() and spec ~= player then
          g_game.look(spec)
          found = now
      end
    end
  end
  if settings.checkPlayer then 
    schedule(500, function()
      checkPlayers()
    end)
  end

  onPlayerPositionChange(function(x,y)
    if not settings.checkPlayer then return end
    if x.z ~= y.z then
      schedule(20, function() checkPlayers() end)
    end
  end)

  onCreatureAppear(function(creature)
    if not settings.checkPlayer then return end
    if creature:isPlayer() and creature:getText() == "" and creature:getPosition().z == posz() and creature ~= player then
        g_game.look(creature)
        found = now
    end
  end)

  local regex = [[You see ([^\(]*) \(Level ([0-9]*)\)((?:.)* of the ([\w ]*),|)]]
  onTextMessage(function(mode, text)
    if not settings.checkPlayer then return end

    local re = regexMatch(text, regex)
    if #re ~= 0 then
        local name = re[1][2]
        local level = re[1][3]
        local guild = re[1][5] or ""

        if guild:len() > 10 then
          guild = guild:sub(1,10) -- change to proper (last) values
          guild = guild.."..."
        end
        local voc
        if text:lower():find("sorcerer") then
            voc = "MS"
        elseif text:lower():find("druid") then
            voc = "ED"
        elseif text:lower():find("knight") then
            voc = "EK"
        elseif text:lower():find("paladin") then
            voc = "RP"
        end
        local creature = getCreatureByName(name)
        if creature then
            creature:setText("\n"..level..voc.."\n"..guild)
        end
        if found and now - found < 500 then
          modules.game_textmessage.clearMessages()
        end
    end
  end)
end

addCheckBox("nextBackpack", "Open Next Loot Container", true, leftPanel, "Auto open next loot container if full - has to have the same ID.")
  local function openNextLootContainer()
    if not settings.nextBackpack then return end
    local containers = getContainers()
    local lootCotaniersIds = CaveBot.GetLootContainers()

    for i, container in ipairs(containers) do
      local cId = container:getContainerItem():getId()
      if containerIsFull(container) then
        if table.find(lootCotaniersIds, cId) then
          for _, item in ipairs(container:getItems()) do
            if item:getId() == cId then
              return g_game.open(item, container)
            end
          end
        end
      end
    end
  end
if true then
  onContainerOpen(function(container, previousContainer)
    schedule(100, function()
      openNextLootContainer()
    end)
  end)

  onAddItem(function(container, slot, item, oldItem)
    schedule(100, function()
      openNextLootContainer()
    end)
  end)
end

addCheckBox("highlightTarget", "Highlight Current Target", true, rightPanel, "Additionaly hightlight current target with red glow")
if true then
  local function forceMarked(creature)
    if target() == creature then
        creature:setMarked("red")
        return schedule(333, function() forceMarked(creature) end)
    end
  end

  onAttackingCreatureChange(function(newCreature, oldCreature)
    if not settings.highlightTarget then return end
      if oldCreature then
          oldCreature:setMarked('')
      end
      if newCreature then
          forceMarked(newCreature)
      end
  end)
end

local function parseCsv(value, mapper)
  local list = {}
  if not value or value:len() == 0 then return list end
  for _, entry in ipairs(string.split(value, ",")) do
    local parsed = entry:trim()
    if mapper then
      parsed = mapper(parsed)
    end
    if parsed and parsed ~= "" then
      table.insert(list, parsed)
    end
  end
  return list
end

local function parsePosition(value)
  local parts = parseCsv(value, tonumber)
  if #parts ~= 3 then return nil end
  return {x = parts[1], y = parts[2], z = parts[3]}
end

addCheckBox("autoReconnect", "Auto Reconnect", false, rightPanel, "Reconnect to the last character after disconnect.")
addScrollBar("autoReconnectDelay", "Reconnect Delay (s)", 1, 120, 5, rightPanel, "Delay in seconds between reconnect attempts.")
addTextEdit("autoReconnectCharacter", "Reconnect Character", "", rightPanel, "Optional: force reconnect to this character name.")
addToggleIcon("autoReconnect", {text = "AR", item = 3031, tooltip = "Auto Reconnect"})
if true then
  settings.autoReconnectLast = settings.autoReconnectLast or ""
  local lastReconnect = 0

  local function isOnline()
    if g_game.isOnline then return g_game.isOnline() end
    if g_game.isConnected then return g_game.isConnected() end
    return g_game.getLocalPlayer() ~= nil
  end

  macro(1000, function()
    if not settings.autoReconnect then return end
    if isOnline() then
      settings.autoReconnectLast = name()
      lastReconnect = now
      return
    end

    local delay = (settings.autoReconnectDelay or 5) * 1000
    if now - lastReconnect < delay then return end

    local charName = settings.autoReconnectCharacter
    charName = (charName and charName:len() > 0) and charName or settings.autoReconnectLast

    local root = g_ui.getRootWidget()
    if root then
      local msgBox = root:recursiveGetChildById('msgBox')
      if msgBox then msgBox:destroy() end
      if root.charactersWindow and root.charactersWindow:isVisible() and charName and charName:len() > 0 then
        relogOnCharacter(charName)
        lastReconnect = now
        return
      end
    end

    if EnterGame and EnterGame.doLogin then
      EnterGame.doLogin()
    elseif EnterGame and EnterGame.show then
      EnterGame.show()
    end
    lastReconnect = now
  end)
end

addCheckBox("bossRaidTimer", "Boss/Raid Timer", false, rightPanel, "Warns before fixed boss/raid schedule.")
addScrollBar("bossRaidWarn", "Boss/Raid Warn (min)", 1, 60, 5, rightPanel, "Minutes before event to warn.")
addToggleIcon("bossRaidTimer", {text = "BR", item = 3031, tooltip = "Boss/Raid Timer"})
if true then
  local bossRaidSchedule = {"01:30","03:30","05:30","07:30","09:30","11:30","13:30","15:30","17:30","19:30","21:30","23:30"}
  local lastAlarmTime = ""
  local configOption = modules.game_bot.contentsPanel.config:getCurrentOption()
  local bossRaidSound = configOption and ("/bot/" .. configOption.text .. "/Alarme/AlarmClock.wav") or nil

  local function timeToSeconds(hhmm)
    local h, m = string.match(hhmm, "(%d+):(%d+)")
    return (tonumber(h) or 0) * 3600 + (tonumber(m) or 0) * 60
  end

  local function getNextRaid()
    local nowDate = os.date("*t")
    local nowValue = nowDate.hour * 3600 + nowDate.min * 60 + nowDate.sec
    for _, timeStr in ipairs(bossRaidSchedule) do
      local raidSec = timeToSeconds(timeStr)
      if raidSec > nowValue then
        return raidSec - nowValue, timeStr
      end
    end
    local firstRaidSec = timeToSeconds(bossRaidSchedule[1])
    return (24 * 3600 - nowValue) + firstRaidSec, bossRaidSchedule[1]
  end

  macro(1000, function()
    if not settings.bossRaidTimer then return end
    local remaining, nextTime = getNextRaid()
    local warnBefore = (tonumber(settings.bossRaidWarn) or 5) * 60
    if remaining <= warnBefore and lastAlarmTime ~= nextTime then
      if bossRaidSound then playSound(bossRaidSound) end
      warn("[Timers] Boss/Raid " .. nextTime .. " in " .. math.ceil(remaining / 60) .. " min.")
      lastAlarmTime = nextTime
    end
  end)
end

addCheckBox("staminaPotion", "Auto Stamina Potion", false, rightPanel, "Use stamina potion when stamina is below set value.")
addItem("staminaPotionId", "Stamina Potion", 36725, rightPanel, "Item ID used for stamina potion.", function(value)
  setIconItem("staminaPotion", value, 36725)
end)
addScrollBar("staminaPotionValue", "Stamina Potion Below", 0, 2520, 2340, rightPanel, "Stamina value in minutes.")
addToggleIcon("staminaPotion", {text = "SP", item = tonumber(settings.staminaPotionId) or 36725, tooltip = "Stamina Potion"})
if true then
  local lastStaminaUse = 0
  macro(1000, function()
    if not settings.staminaPotion then return end
    local itemId = tonumber(settings.staminaPotionId or 0)
    if itemId < 100 then return end
    local minStamina = tonumber(settings.staminaPotionValue or 0)
    local player = g_game.getLocalPlayer()
    if not player then return end
    if minStamina <= 0 or player:getStamina() > minStamina then return end
    if vBot.isUsingPotion or now - lastStaminaUse < 1500 then return end

    if g_game.useInventoryItem then
      g_game.useInventoryItem(itemId)
      lastStaminaUse = now
      return
    end

    local potion = findItem(itemId)
    if potion then
      use(potion)
      lastStaminaUse = now
    end
  end)
end

addCheckBox("storeSell", "Store Sell Item", false, rightPanel, "Use store sell item to sell loot.")
addItem("storeSellItemId", "Store Sell Item", 54995, rightPanel, "Item ID for store sell item.", function(value)
  setIconItem("storeSell", value, 54995)
end)
addCheckBox("storeBank", "Store Bank Item", false, rightPanel, "Use store bank item to deposit gold.")
addItem("storeBankItemId", "Store Bank Item", 54991, rightPanel, "Item ID for store bank item.", function(value)
  setIconItem("storeBank", value, 54991)
end)
addScrollBar("storeItemDelay", "Store Item Delay (s)", 1, 60, 5, rightPanel, "Delay in seconds between sell and bank.")
addScrollBar("storeItemInterval", "Store Item Interval (s)", 5, 300, 30, rightPanel, "Interval between sell/bank cycles.")
addToggleIcon("storeSell", {text = "SS", item = tonumber(settings.storeSellItemId) or 54995, tooltip = "Store Sell"})
addToggleIcon("storeBank", {text = "SB", item = tonumber(settings.storeBankItemId) or 54991, tooltip = "Store Bank"})
if true then
  local lastStoreUse = 0

  local function useStoreItem(itemId)
    if itemId < 100 then return end
    if g_game.useInventoryItem then
      g_game.useInventoryItem(itemId)
      return
    end
    local item = findItem(itemId)
    if item then use(item) end
  end

  macro(1000, function()
    if not settings.storeSell and not settings.storeBank then return end
    local interval = (settings.storeItemInterval or 30) * 1000
    if now - lastStoreUse < interval then return end
    local delay = (settings.storeItemDelay or 5) * 1000
    if settings.storeSell then
      useStoreItem(tonumber(settings.storeSellItemId or 0))
    end
    if settings.storeBank then
      if settings.storeSell then
        schedule(delay, function()
          useStoreItem(tonumber(settings.storeBankItemId or 0))
        end)
      else
        useStoreItem(tonumber(settings.storeBankItemId or 0))
      end
    end
    lastStoreUse = now
  end)
end

addCheckBox("houseTrainer", "House Trainer", false, rightPanel, "Use wands on training dummy when nearby.")
addTextEdit("houseTrainerDummyPos", "Dummy Position", "1051,1043,7", rightPanel, "Position of the dummy (x,y,z).")
local function updateHouseTrainerIcon()
  local wandId = settings.houseTrainerWands and settings.houseTrainerWands:match("(%d+)")
  local iconItem = tonumber(wandId) or tonumber(settings.houseTrainerDummyId) or 54005
  setIconItem("houseTrainer", iconItem, 54005)
end

addTextEdit("houseTrainerDummyId", "Dummy Item ID", "54005", rightPanel, "Item ID used for the training dummy.", function()
  updateHouseTrainerIcon()
end)
addTextEdit("houseTrainerWands", "Wand IDs", "55486,55484,55634,55485", rightPanel, "Comma-separated wand IDs to use.", function()
  updateHouseTrainerIcon()
end)
addScrollBar("houseTrainerRange", "Trainer Range", 1, 10, 3, rightPanel, "Maximum distance to dummy.")
addScrollBar("houseTrainerDelay", "Trainer Delay (ms)", 200, 5000, 1500, rightPanel, "Delay between wand uses.")
local houseTrainerIconItem = tonumber(settings.houseTrainerDummyId) or 54005
if settings.houseTrainerWands and settings.houseTrainerWands:len() > 0 then
  houseTrainerIconItem = tonumber(settings.houseTrainerWands:match("(%d+)")) or houseTrainerIconItem
end
addToggleIcon("houseTrainer", {text = "HT", item = houseTrainerIconItem, tooltip = "House Trainer"})
updateHouseTrainerIcon()
if true then
  local lastTrainerUse = 0

  local function getPriorityWand(wands)
    for _, id in ipairs(wands) do
      local item = findItem(id)
      if item then return item end
    end
    return nil
  end

  local function getDummyThing(dummyPos, dummyId)
    local tile = g_map.getTile(dummyPos)
    if not tile then return nil end
    for _, thing in ipairs(tile:getThings()) do
      if thing:getId() == dummyId then return thing end
    end
    return nil
  end

  macro(200, function()
    if not settings.houseTrainer then return end
    local dummyPos = parsePosition(settings.houseTrainerDummyPos)
    if not dummyPos then return end
    local dummyId = tonumber(settings.houseTrainerDummyId or 0)
    if dummyId <= 0 then return end
    local wands = parseCsv(settings.houseTrainerWands, tonumber)
    if #wands == 0 then return end
    local delay = tonumber(settings.houseTrainerDelay or 1500)
    if now - lastTrainerUse < delay then return end
    if distanceFromPlayer(dummyPos) > (tonumber(settings.houseTrainerRange or 3)) then return end

    local dummyThing = getDummyThing(dummyPos, dummyId)
    if not dummyThing then return end
    local wandItem = getPriorityWand(wands)
    if not wandItem then return end
    if g_game.useWith then
      g_game.useWith(wandItem, dummyThing)
    else
      useWith(wandItem, dummyThing)
    end
    lastTrainerUse = now
  end)
end

addCheckBox("bossDodge", "Boss Dodge", false, rightPanel, "Move away from forbidden boss tiles.")
addTextEdit("bossDodgeItemId", "Boss Dodge Item ID", "55636", rightPanel, "Item ID to avoid when boss is active.", function(value)
  setIconItem("bossDodge", value, 55636)
end)
addScrollBar("bossDodgeRange", "Boss Dodge Range", 1, 10, 7, rightPanel, "Search range for a safe tile.")
addToggleIcon("bossDodge", {text = "BD", item = tonumber(settings.bossDodgeItemId) or 55636, tooltip = "Boss Dodge"})
if true then
  local function hasItemOnPos(pos, itemId)
    local tile = g_map.getTile(pos)
    if tile then
      for _, thing in ipairs(tile:getThings()) do
        if thing:getId() == itemId then return true end
      end
    end
    return false
  end

  local function getSafeTile(playerPos, itemId, range)
    local bestPos
    local shortestDist = 99999
    for x = -range, range do
      for y = -range, range do
        local checkPos = {x = playerPos.x + x, y = playerPos.y + y, z = playerPos.z}
        local tile = g_map.getTile(checkPos)
        if tile and tile:isWalkable() and tile:isPathable() then
          if not hasItemOnPos(checkPos, itemId) then
            local dist = getDistanceBetween(playerPos, checkPos)
            if dist < shortestDist then
              shortestDist = dist
              bestPos = checkPos
            end
          end
        end
      end
    end
    return bestPos
  end

  macro(100, function()
    if not settings.bossDodge then return end
    local itemId = tonumber(settings.bossDodgeItemId or 0)
    if itemId <= 0 then return end
    local playerPos = pos()
    if not hasItemOnPos(playerPos, itemId) then return end
    if g_game.isAttacking() or g_game.isFollowing() then g_game.stop() end
    local safeSpot = getSafeTile(playerPos, itemId, tonumber(settings.bossDodgeRange or 7))
    if safeSpot and (playerPos.x ~= safeSpot.x or playerPos.y ~= safeSpot.y) then
      autoWalk(safeSpot, 100, {ignoreNonPathable = true, precision = 0})
    end
  end)
end

addCheckBox("buffRenew", "Buff Renew", false, rightPanel, "Recast buff spell when it expires.")
addTextEdit("buffRenewSpell", "Buff Spell", "utito tempo san", rightPanel, "Spell to keep active (e.g. utito tempo).")
addScrollBar("buffRenewMana", "Buff Min Mana %", 0, 100, 20, rightPanel, "Minimum mana percent to cast.")
addScrollBar("buffRenewDelay", "Buff Delay (s)", 1, 60, 5, rightPanel, "Delay between buff attempts.")
addToggleIcon("buffRenew", {text = "BF", item = 3031, tooltip = "Buff Renew"})
if true then
  local lastBuff = 0
  macro(500, function()
    if not settings.buffRenew then return end
    if not settings.buffRenewSpell or settings.buffRenewSpell:len() == 0 then return end
    if hasPartyBuff() or isInPz() then return end
    if manapercent() < (settings.buffRenewMana or 0) then return end
    local delay = (settings.buffRenewDelay or 5) * 1000
    if now - lastBuff < delay then return end
    castSpell(settings.buffRenewSpell)
    lastBuff = now
  end)
end

addCheckBox("taskRenew", "Task Renew", false, rightPanel, "Send task command when no task is active.")
addTextEdit("taskRenewNpc", "Task NPC", "", rightPanel, "Optional NPC name to be nearby.")
addTextEdit("taskRenewCommand", "Task Command", "!taskrenew", rightPanel, "Command to request a task.")
addScrollBar("taskRenewDelay", "Task Renew Delay (s)", 5, 120, 120, rightPanel, "Delay between attempts.")
addToggleIcon("taskRenew", {text = "TR", item = 3031, tooltip = "Task Renew"})
if true then
  local lastTaskRenew = 0

  local function hasTaskNpc()
    if not settings.taskRenewNpc or settings.taskRenewNpc:len() == 0 then return true end
    for _, spec in ipairs(getSpectators()) do
      if spec:isNpc() and spec:getName():lower() == settings.taskRenewNpc:lower() and distanceFromPlayer(spec:getPosition()) <= 3 then
        return true
      end
    end
    return false
  end

  macro(1000, function()
    if not settings.taskRenew then return end
    if not hasTaskNpc() then return end
    if not settings.taskRenewCommand or settings.taskRenewCommand:len() == 0 then return end
    local delay = (settings.taskRenewDelay or 120) * 1000
    if now - lastTaskRenew < delay then return end
    say(settings.taskRenewCommand)
    lastTaskRenew = now
  end)
end

addCheckBox("turboFollow", "Turbo Follow", false, rightPanel, "Aggressive follow for selected player.")
addTextEdit("turboFollowName", "Turbo Follow Name", "", rightPanel, "Name of the creature to follow.")
addScrollBar("turboFollowDelay", "Turbo Follow Delay (ms)", 50, 2000, 100, rightPanel, "Delay between follow steps.")
addScrollBar("turboFollowDistance", "Turbo Follow Distance", 1, 10, 1, rightPanel, "Follow when farther than this distance.")
addToggleIcon("turboFollow", {text = "TF", item = 3031, tooltip = "Turbo Follow"})
if true then
  local useIds = {433,435,482,1948,1968,5542,7771,9116,12799,17230,20469,20474,20488,20489,20895,20896,28209,28210,28656,31129,31130,31262,33770,34324,43374}
  local stepIds = {166,167,413,427,427,428,433,437,438,465,468,566,855,856,857,1947,1950,1951,1952,1953,1954,1955,1956,1957,1958,1977,1978,4823,5081,5257,5258,5259,7881,7888,8657,8658,8690,8932,10206,11707,11709,14133,15144,15145,15146,15147,15718,16272,17394,17395,15590,15591,20123,20124,20142,20224,20225,20253,20254,20255,20256,20257,20258,20259,20328,20329,20330,20331,20332,20333,20334,20335,20336,20491,20492,20493,20494,20495,20496,20750,20751,20752,20753,20754,20755,21365,21564,21566,21568,21570,21156,22517,22565,22566,22749,29111,31907,39919,39921,39923,39925,40262,40263,40279,40281,40296,40298,40302,40428,40430,40432,40434,42619,42621,42623,42632,43134,42395,42391,23483,1967,1966,293,294,369,370,385,394,411,412,414,426,432,434,469,476,483,484,485,594,595,600,601,602,607,609,610,615,868,874,877,1066,1067,1080,1156,4824,4825,4826,5544,5691,5731,5763,6127,6128,6129,6130,6172,6173,6754,6755,6756,6916,7053,7181,7182,7476,7477,7478,7479,7515,7516,7517,7518,7520,7521,7522,7729,7730,7731,7732,7733,7734,7735,7736,7737,7755,7764,8144,8709,8924,12200,12236,12797,12798,12939,12940,12941,12942,12943,12944,12945,12946,12947,12948,12949,12950,12951,12952,12953,12954,12955,12956,12957,12958,12959,12960,14134,16265,16266,16267,16268,16269,16270,16271,16696,16697,16698,16699,16700,16701,16702,16703,16785,16786,16787,16788,16789,16790,16791,16792,17239,18642,18643,18644,18645,18646,18647,18648,18649,19143,19220,20260,20261,20262,20263,20344,20470,20471,20472,20073,21034,21342,21344,21971,21972,21973,22157,22748,23364,27628,28655,30452,30453,31168,32020,33709,34166,34255,38831,38832,43372,6920,505,628,775,878,1756,1761,1949,1959,5022,5756,8193,11552,11553,12795,15320,19243,20142,21739,21740,21741,21743,22106,22747,22761,23482,25047,25049,25051,25052,25053,25054,25055,25056,25057,25058,27589,27590,27658,28671,29975,29979,29980,32974,33004,33005,33006,33007,33790,34111,35502,36972,37000,37001,31469,37065,5068,5069,44027,32979,23483}
  local lastKnownX, lastKnownY, lastKnownZ = 0, 0, 0
  local hasLastPos, lastInteraction, lastFollow = false, 0, 0

  local function findTarget(name)
    if not name or #name < 1 then return nil end
    local player = g_game.getLocalPlayer()
    if not player then return nil end
    local specs = g_map.getSpectators(player:getPosition(), false)
    for _, c in ipairs(specs) do
      if c:isPlayer() and c ~= player and c:getName():lower() == name:lower() then return c end
    end
    return nil
  end

  local function getDist(pos1, pos2)
    return math.max(math.abs(pos1.x - pos2.x), math.abs(pos1.y - pos2.y))
  end

  local function checkSurroundings(pPos, interactionDelay)
    if now - lastInteraction < interactionDelay then return end
    for x = -1, 1 do
      for y = -1, 1 do
        local checkPos = {x = pPos.x + x, y = pPos.y + y, z = pPos.z}
        local tile = g_map.getTile(checkPos)
        if tile then
          for _, thing in ipairs(tile:getThings()) do
            if thing:isItem() then
              local id = thing:getId()
              if table.find(stepIds, id) then
                autoWalk(checkPos, 10, {ignoreNonPathable = true, precision = 0})
                lastInteraction = now
                return
              end
              if table.find(useIds, id) then
                g_game.use(thing)
                lastInteraction = now
                return
              end
            end
          end
        end
      end
    end
  end

  macro(50, function()
    if not settings.turboFollow or (CaveBot and CaveBot.isOn and CaveBot.isOn()) then return end
    local player = g_game.getLocalPlayer()
    if not player then return end
    if not settings.turboFollowName or settings.turboFollowName:len() == 0 then return end
    local delay = tonumber(settings.turboFollowDelay or 100)
    if now - lastFollow < delay then return end
    local myPos = player:getPosition()
    local targetName = settings.turboFollowName
    local target = findTarget(targetName)
    local followDistance = tonumber(settings.turboFollowDistance or 1)
    if target then
      local tPos = target:getPosition()
      if tPos then
        lastKnownX, lastKnownY, lastKnownZ = tPos.x, tPos.y, tPos.z
        hasLastPos = true
        if getDist(myPos, tPos) > followDistance then
          autoWalk(tPos, 10, {ignoreNonPathable = true, precision = 1})
        end
      end
    elseif hasLastPos then
      local lastPos = {x = lastKnownX, y = lastKnownY, z = lastKnownZ}
      if lastPos.x ~= 0 then
        if getDist(myPos, lastPos) > 1 then
          autoWalk(lastPos, 10, {ignoreNonPathable = true, precision = 1})
        else
          checkSurroundings(lastPos, delay)
        end
      end
    end
    lastFollow = now
  end)

  onTextMessage(function(mode, text)
    if not settings.turboFollow then return end
    if string.find(text, "You see") then
      local name = string.match(text, "You see ([^%.%(]+)")
      if name then
        name = string.gsub(name, "^%s*(.-)%s*$", "%1")
        settings.turboFollowName = name
      end
    end
  end)
end

addCheckBox("antiPushDrop", "Anti-Push Drop", false, rightPanel, "Drop items under you to avoid being pushed.")
addTextEdit("antiPushDropItems", "Anti-Push Items", "3031,3035", rightPanel, "Comma-separated item IDs to drop.", function(value)
  local items = parseCsv(value, tonumber) or {}
  setIconItem("antiPushDrop", items[1] or 3031, 3031)
end)
addScrollBar("antiPushDropMax", "Anti-Push Stack Max", 1, 20, 10, rightPanel, "Max stacked items under you.")
addScrollBar("antiPushDropDelay", "Anti-Push Delay (ms)", 100, 5000, 600, rightPanel, "Delay between drops.")
local antiPushItems = parseCsv(settings.antiPushDropItems, tonumber) or {}
local antiPushIconItem = antiPushItems[1] or 3031
addToggleIcon("antiPushDrop", {text = "AP", item = antiPushIconItem, tooltip = "Anti-Push Drop"})
if true then
  local lastDrop = 0

  local function antiPush()
    if not settings.antiPushDrop then return end
    local delay = tonumber(settings.antiPushDropDelay or 600)
    if now - lastDrop < delay then return end
    local ids = parseCsv(settings.antiPushDropItems, tonumber)
    if #ids == 0 then return end

    local tile = g_map.getTile(pos())
    if tile and tile:getThingCount() < tonumber(settings.antiPushDropMax or 10) then
      local thing = tile:getTopThing()
      if thing and not thing:isNotMoveable() then
        for _, id in ipairs(ids) do
          if id ~= thing:getId() then
            local dropItem = findItem(id)
            if dropItem then
              g_game.move(dropItem, pos(), 2)
              lastDrop = now
              return
            end
          end
        end
      end
    end
  end

  macro(100, function()
    antiPush()
  end)

  onPlayerPositionChange(function()
    antiPush()
  end)
end
