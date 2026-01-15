setDefaultTab("Main")

-- securing storage namespace
local panelName = "extras"
if not storage[panelName] then
  storage[panelName] = {}
end
local settings = storage[panelName]

-- basic elements
extrasWindow = UI.createWindow('ExtrasWindow', rootWidget)
extrasWindow:hide()
extrasWindow.closeButton.onClick = function(widget)
  extrasWindow:hide()
end

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
end

local addItem = function(id, title, defaultItem, dest, tooltip)
  local widget = UI.createWidget('ExtrasItem', dest)
  widget.text:setText(title)
  widget.text:setTooltip(tooltip)
  widget.item:setTooltip(tooltip)
  widget.item:setItemId(settings[id] or defaultItem)
  widget.item.onItemChange = function(widget)
    settings[id] = widget:getItemId()
  end
  settings[id] = settings[id] or defaultItem
end

local addTextEdit = function(id, title, defaultValue, dest, tooltip)
  local widget = UI.createWidget('ExtrasTextEdit', dest)
  widget.text:setText(title)
  widget.textEdit:setText(settings[id] or defaultValue or "")
  widget.text:setTooltip(tooltip)
  widget.textEdit.onTextChange = function(widget,text)
    settings[id] = text
  end
  settings[id] = settings[id] or defaultValue or ""
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

UI.Button("vBot Settings and Scripts", function()
  extrasWindow:show()
  extrasWindow:raise()
  extrasWindow:focus()
end)
UI.Separator()

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
        if not modules.game_walking.wsadWalking then return end
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
    local wsadWalking = modules.game_walking.wsadWalking
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
    local wsadWalking = modules.game_walking.wsadWalking
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
    local wsadWalking = modules.game_walking.wsadWalking
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

addCheckBox("autoReconnect", "Auto Reconnect", false, rightPanel, "Reconnect to the last character after disconnect.")
addScrollBar("autoReconnectDelay", "Reconnect Delay (s)", 1, 120, 5, rightPanel, "Delay in seconds between reconnect attempts.")
addTextEdit("autoReconnectCharacter", "Reconnect Character", "", rightPanel, "Optional: force reconnect to this character name.")
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

    local root = g_ui.getRootWidget()
    if not root or not root.charactersWindow or not root.charactersWindow:isVisible() then return end

    local charName = settings.autoReconnectCharacter
    charName = (charName and charName:len() > 0) and charName or settings.autoReconnectLast
    if not charName or charName:len() == 0 then return end

    relogOnCharacter(charName)
    lastReconnect = now
  end)
end

addCheckBox("bossRaidTimer", "Boss/Raid Timer", false, rightPanel, "Warns before fixed boss/raid schedule.")
addScrollBar("bossRaidWarn", "Boss/Raid Warn (min)", 1, 60, 10, rightPanel, "Minutes before event to warn.")
if true then
  local bossRaidSchedule = {
    {type = "Boss", name = "Boss", hour = 20, minute = 0},
    {type = "Raid", name = "Raid", hour = 21, minute = 0}
  }
  local bossRaidState = {}

  local function nextScheduleTime(event)
    local nowDate = os.date("*t")
    local target = {
      year = nowDate.year,
      month = nowDate.month,
      day = nowDate.day,
      hour = event.hour,
      min = event.minute,
      sec = 0
    }
    local targetTime = os.time(target)
    if targetTime <= os.time() then
      target.day = target.day + 1
      targetTime = os.time(target)
    end
    return targetTime
  end

  macro(1000, function()
    if not settings.bossRaidTimer then return end
    local warnBefore = (settings.bossRaidWarn or 10) * 60
    local nowTime = os.time()
    for _, event in ipairs(bossRaidSchedule) do
      local key = event.type .. ":" .. event.name
      local nextTime = nextScheduleTime(event)
      local state = bossRaidState[key] or {}
      if state.nextTime ~= nextTime then
        state = {nextTime = nextTime, warnedSoon = false, warnedStart = false}
        bossRaidState[key] = state
      end

      local timeLeft = nextTime - nowTime
      if timeLeft <= 0 then
        if not state.warnedStart then
          warn("[Timers] " .. event.type .. " " .. event.name .. " started.")
          state.warnedStart = true
        end
      elseif timeLeft <= warnBefore and not state.warnedSoon then
        local minutes = math.ceil(timeLeft / 60)
        warn("[Timers] " .. event.type .. " " .. event.name .. " in " .. minutes .. " min.")
        state.warnedSoon = true
      end
    end
  end)
end

addCheckBox("staminaPotion", "Auto Stamina Potion", false, rightPanel, "Use stamina potion when stamina is below set value.")
addItem("staminaPotionId", "Stamina Potion", 0, rightPanel, "Item ID used for stamina potion.")
addScrollBar("staminaPotionValue", "Stamina Potion Below", 0, 2520, 900, rightPanel, "Stamina value in minutes.")
if true then
  local lastStaminaUse = 0
  macro(1000, function()
    if not settings.staminaPotion then return end
    local itemId = tonumber(settings.staminaPotionId or 0)
    if itemId < 100 then return end
    local minStamina = tonumber(settings.staminaPotionValue or 0)
    if minStamina <= 0 or stamina() >= minStamina then return end
    if vBot.isUsingPotion or now - lastStaminaUse < 1500 then return end

    local potion = findItem(itemId)
    if potion then
      use(potion)
      lastStaminaUse = now
    end
  end)
end

addCheckBox("storeSell", "Store Sell Item", false, rightPanel, "Use store sell item to sell loot.")
addItem("storeSellItemId", "Store Sell Item", 0, rightPanel, "Item ID for store sell item.")
addCheckBox("storeBank", "Store Bank Item", false, rightPanel, "Use store bank item to deposit gold.")
addItem("storeBankItemId", "Store Bank Item", 0, rightPanel, "Item ID for store bank item.")
addScrollBar("storeItemDelay", "Store Item Delay (s)", 1, 60, 5, rightPanel, "Delay in seconds between uses.")
if true then
  local lastStoreUse = {sell = 0, bank = 0}

  local function useStoreItem(itemId, key)
    if itemId < 100 then return end
    local delay = (settings.storeItemDelay or 5) * 1000
    if now - lastStoreUse[key] < delay then return end
    local item = findItem(itemId)
    if item then
      use(item)
      lastStoreUse[key] = now
    end
  end

  macro(1000, function()
    if settings.storeSell then
      useStoreItem(tonumber(settings.storeSellItemId or 0), "sell")
    end
    if settings.storeBank then
      useStoreItem(tonumber(settings.storeBankItemId or 0), "bank")
    end
  end)
end

addCheckBox("houseTrainer", "House Trainer", false, rightPanel, "Attack training dummies when in protection zone.")
addTextEdit("houseTrainerNames", "Trainer Names", "training", rightPanel, "Comma-separated trainer names to attack.")
addScrollBar("houseTrainerRange", "Trainer Range", 1, 10, 3, rightPanel, "Maximum distance to trainer.")
if true then
  local function isTrainer(creature, names)
    local cname = creature:getName():lower()
    for _, name in ipairs(names) do
      if cname:find(name, 1, true) then
        return true
      end
    end
    return false
  end

  macro(1000, function()
    if not settings.houseTrainer or not isInPz() then return end
    local names = parseCsv(settings.houseTrainerNames, function(value) return value:lower() end)
    if #names == 0 then return end
    if g_game.isAttacking() and target() and not isTrainer(target(), names) then return end
    local maxRange = tonumber(settings.houseTrainerRange or 3)

    for _, spec in ipairs(getSpectators()) do
      if (spec:isNpc() or spec:isMonster()) and distanceFromPlayer(spec:getPosition()) <= maxRange and isTrainer(spec, names) then
        g_game.attack(spec)
        return
      end
    end
  end)
end

addCheckBox("bossDodge", "Boss Dodge", false, rightPanel, "Step away from bosses when too close.")
addTextEdit("bossDodgeNames", "Boss Names", "", rightPanel, "Comma-separated boss names (uses EQ Manager list if empty).")
addScrollBar("bossDodgeRange", "Boss Dodge Range", 1, 3, 1, rightPanel, "Dodge when boss is within range.")
addScrollBar("bossDodgeDelay", "Boss Dodge Delay (ms)", 100, 2000, 600, rightPanel, "Delay between dodge steps.")
if true then
  local lastDodge = 0

  local function getBossNames()
    local names = {}
    if settings.bossDodgeNames and settings.bossDodgeNames:len() > 0 then
      names = parseCsv(settings.bossDodgeNames, function(value) return value:lower() end)
    elseif storage.EquipperPanel and type(storage.EquipperPanel.bosses) == "table" then
      for _, boss in ipairs(storage.EquipperPanel.bosses) do
        if boss and boss:len() > 0 then
          table.insert(names, boss:lower())
        end
      end
    end
    return names
  end

  local function isBoss(creature)
    if not creature then return false end
    local bossNames = getBossNames()
    if #bossNames == 0 then return false end
    local cname = creature:getName():lower()
    for _, name in ipairs(bossNames) do
      if cname:find(name, 1, true) then
        return true
      end
    end
    return false
  end

  local function getDodgePos(bossPos)
    local playerPos = pos()
    local dirs = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {-1, 1}, {1, -1}, {-1, -1}}
    local bestPos
    local bestDist = getDistanceBetween(playerPos, bossPos)
    for _, dir in ipairs(dirs) do
      local candidate = {x = playerPos.x + dir[1], y = playerPos.y + dir[2], z = playerPos.z}
      local tile = g_map.getTile(candidate)
      if tile and tile:isWalkable(false) and not tile:hasCreature() then
        local dist = getDistanceBetween(candidate, bossPos)
        if dist > bestDist then
          bestDist = dist
          bestPos = candidate
        end
      end
    end
    return bestPos
  end

  macro(50, function()
    if not settings.bossDodge then return end
    local boss = target()
    if not boss or not isBoss(boss) then return end
    local range = tonumber(settings.bossDodgeRange or 1)
    if distanceFromPlayer(boss:getPosition()) > range then return end
    local delay = tonumber(settings.bossDodgeDelay or 600)
    if now - lastDodge < delay then return end
    local dodgePos = getDodgePos(boss:getPosition())
    if dodgePos then
      autoWalk(dodgePos, 20, {ignoreNonPathable = true, precision = 1})
      lastDodge = now
    end
  end)
end

addCheckBox("buffRenew", "Buff Renew", false, rightPanel, "Recast buff spell when it expires.")
addTextEdit("buffRenewSpell", "Buff Spell", "", rightPanel, "Spell to keep active (e.g. utito tempo).")
addScrollBar("buffRenewMana", "Buff Min Mana %", 0, 100, 20, rightPanel, "Minimum mana percent to cast.")
addScrollBar("buffRenewDelay", "Buff Delay (s)", 1, 60, 5, rightPanel, "Delay between buff attempts.")
if true then
  local lastBuff = 0
  macro(500, function()
    if not settings.buffRenew then return end
    if not settings.buffRenewSpell or settings.buffRenewSpell:len() == 0 then return end
    if isBuffed() or manapercent() < (settings.buffRenewMana or 0) then return end
    local delay = (settings.buffRenewDelay or 5) * 1000
    if now - lastBuff < delay then return end
    castSpell(settings.buffRenewSpell)
    lastBuff = now
  end)
end

addCheckBox("taskRenew", "Task Renew", false, rightPanel, "Send task command when no task is active.")
addTextEdit("taskRenewNpc", "Task NPC", "", rightPanel, "Optional NPC name to be nearby.")
addTextEdit("taskRenewCommand", "Task Command", "task", rightPanel, "Command to request a task.")
addScrollBar("taskRenewDelay", "Task Renew Delay (s)", 5, 120, 30, rightPanel, "Delay between attempts.")
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
    local taskData = storage.caveBotTasker
    if not settings.taskRenew or not taskData or taskData.inProgress then return end
    if not hasTaskNpc() then return end
    if not settings.taskRenewCommand or settings.taskRenewCommand:len() == 0 then return end
    local delay = (settings.taskRenewDelay or 30) * 1000
    if now - lastTaskRenew < delay then return end
    say(settings.taskRenewCommand)
    lastTaskRenew = now
  end)
end

addCheckBox("turboFollow", "Turbo Follow", false, rightPanel, "Aggressive follow for selected player.")
addTextEdit("turboFollowName", "Turbo Follow Name", "", rightPanel, "Name of the creature to follow.")
addScrollBar("turboFollowDelay", "Turbo Follow Delay (ms)", 50, 2000, 100, rightPanel, "Delay between follow steps.")
addScrollBar("turboFollowDistance", "Turbo Follow Distance", 1, 10, 2, rightPanel, "Follow when farther than this distance.")
if true then
  local toFollowPos = {}
  local lastFollow = 0

  local function updateFollowPos(creature)
    if not creature then return end
    toFollowPos[creature:getPosition().z] = creature:getPosition()
  end

  macro(50, function()
    if not settings.turboFollow or (CaveBot and CaveBot.isOn and CaveBot.isOn()) then return end
    if not settings.turboFollowName or settings.turboFollowName:len() == 0 then return end
    local delay = tonumber(settings.turboFollowDelay or 100)
    if now - lastFollow < delay then return end
    local followName = settings.turboFollowName
    local creature = getCreatureByName(followName)
    if creature then
      updateFollowPos(creature)
    end
    if player:isWalking() then return end
    local followPos = toFollowPos[posz()]
    if not followPos or distanceFromPlayer(followPos) <= (settings.turboFollowDistance or 2) then return end
    autoWalk(followPos, 20, {ignoreNonPathable = true, precision = 1})
    lastFollow = now
  end)

  onCreaturePositionChange(function(creature, oldPos, newPos)
    if not settings.turboFollow or not settings.turboFollowName or settings.turboFollowName:len() == 0 then return end
    if creature:getName():lower() == settings.turboFollowName:lower() and newPos then
      toFollowPos[newPos.z] = newPos
    end
  end)
end

addCheckBox("antiPushDrop", "Anti-Push Drop", false, rightPanel, "Drop items under you to avoid being pushed.")
addTextEdit("antiPushDropItems", "Anti-Push Items", "3031", rightPanel, "Comma-separated item IDs to drop.")
addScrollBar("antiPushDropDelay", "Anti-Push Delay (ms)", 100, 5000, 600, rightPanel, "Delay between drops.")
if true then
  local lastDrop = 0

  macro(100, function()
    if not settings.antiPushDrop then return end
    local delay = tonumber(settings.antiPushDropDelay or 600)
    if now - lastDrop < delay then return end
    local ids = parseCsv(settings.antiPushDropItems, tonumber)
    if #ids == 0 then return end

    local tile = g_map.getTile(pos())
    if not tile then return end
    for _, item in ipairs(tile:getItems()) do
      if table.find(ids, item:getId()) then
        return
      end
    end

    for _, id in ipairs(ids) do
      local item = findItem(id)
      if item then
        local amount = item:isStackable() and 1 or item:getCount()
        g_game.move(item, pos(), amount)
        lastDrop = now
        return
      end
    end
  end)
end
