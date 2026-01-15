local label

local function ensureLabel()
    if label then return label end

    local inventoryWindow = modules.game_inventory and modules.game_inventory.inventoryWindow
    if not inventoryWindow then return nil end

    local quiverSlot = inventoryWindow:recursiveGetChildById('slot5')
    if not quiverSlot then return nil end

    label = quiverSlot.count
    label = label or g_ui.loadUIFromString([[
Label
  id: count
  color: #bfbfbf
  font: verdana-11px-rounded
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.bottom: parent.bottom
  text-align: right
  margin-right: 3
  margin-left: 3
  text:
]], quiverSlot)
    return label
end


function getQuiverAmount()
    -- old tibia
    if g_game.getClientVersion() < 1000 then return end

    local quiverLabel = ensureLabel()
    if not quiverLabel then return end


    local isQuiverEquipped = getRight() and getRight():isContainer() or false
    local quiver = isQuiverEquipped and getContainerByItem(getRight():getId())
    local count = 0

    if quiver then
        for i, item in ipairs(quiver:getItems()) do
            count = count + item:getCount()
        end
    else
        return quiverLabel:setText("")
    end

    return quiverLabel:setText(count)
end
getQuiverAmount()

onContainerOpen(function(container, previousContainer)
    getQuiverAmount()
end)

onContainerClose(function(container)
    getQuiverAmount()
end)
  
onAddItem(function(container, slot, item, oldItem)
    getQuiverAmount()
end)

onRemoveItem(function(container, slot, item)
    getQuiverAmount()
end)

onContainerUpdateItem(function(container, slot, item, oldItem)
    getQuiverAmount()
end)
