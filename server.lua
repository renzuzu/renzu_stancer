

ESX = nil
QBCore = nil
RegisterUsableItem = nil
Initialized()
stancer = {}

Citizen.CreateThread(function()
  local ret = SqlFunc(Config.Mysql,'fetchAll','SELECT * FROM renzu_stancer', {})
  for k,v in pairs(ret) do
    if stancer[v.plate] == nil then stancer[v.plate] = {} end
    stancer[v.plate].plate = v.plate
    stancer[v.plate].stancer = json.decode(v.setting)
    stancer[v.plate].online = false
  end

  for k,v in ipairs(GetAllVehicles()) do
    local plate = GetVehicleNumberPlateText(v)
    if stancer[plate] and plate == stancer[plate].plate then
      if stancer[plate].stancer then
        local ent = Entity(v).state
        ent.stancer = stancer[plate].stancer
        ent.online = true
      end
    end
  end
end)

function SaveStancer(ob)
    local plate = string.gsub(ob.plate, '^%s*(.-)%s*$', '%1')
    local result = SqlFunc(Config.Mysql,'fetchAll','SELECT * FROM renzu_stancer WHERE TRIM(plate) = @plate', {['@plate'] = plate})
    if result[1] == nil then
        SqlFunc(Config.Mysql,'execute','INSERT INTO renzu_stancer (plate, setting) VALUES (@plate, @stancer)', {
            ['@plate']   = ob.plate,
            ['@stancer']   = '[]',
        })
    elseif result[1] then
        SqlFunc(Config.Mysql,'execute','UPDATE renzu_stancer SET setting = @setting WHERE TRIM(plate) = @plate', {
          ['@plate']   = plate,
          ['@setting']   = json.encode(ob.setting),
        })
    end
end

function firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

Citizen.CreateThread(function()
  c = 0
  if Config.Framework == 'ESX' then
    for k,v in pairs(Config.items) do
      c = c + 1
      local stancername = string.lower(v)
      local label = string.upper(v)
      foundRow = SqlFunc(Config.Mysql,'fetchAll',"SELECT * FROM items WHERE name = @name", {
        ['@name'] = stancername
      })
      if foundRow[1] == nil then
        local weight = 'limit'
        if Config.weight_type then
          SqlFunc(Config.Mysql,'execute',"INSERT INTO items (name, label, weight) VALUES (@name, @label, @weight)", {
            ['@name'] = stancername,
            ['@label'] = ""..firstToUpper(stancername).."",
            ['@weight'] = Config.weight
          })
          print("Inserting "..stancername.."")
        else
          SqlFunc(Config.Mysql,'execute',"INSERT INTO items (name, label) VALUES (@name, @label)", {
            ['@name'] = stancername,
            ['@label'] = ""..firstToUpper(stancername).."",
          })
          print("Inserting "..stancername)
        end
      end
    end
  end

  while ESX and QBCore == nil do Wait(10) print(ESX,QBCore) end

  if Config.Framework ~= 'Standalone' then
    for k,v in pairs(Config.items) do
      local stanceritem = string.lower(v)
      print("register item", v)
      RegisterUsableItem(stanceritem, function(source)
        local xPlayer = GetPlayerFromId(source)
        local veh = GetVehiclePedIsIn(GetPlayerPed(source),false)
        if stanceritem ~= nil and veh ~= 0 then
          xPlayer.removeInventoryItem(stanceritem, 1)
          AddStancerKit(veh)
        end
      end)
    end
  end
  print(" STANCER LOADED ")
end)

function AddStancerKit(veh)
  local veh = veh
  if veh == nil then veh = GetVehiclePedIsIn(GetPlayerPed(source),false) end
  plate = GetVehicleNumberPlateText(veh)
  if not stancer[plate] then
    stancer[plate] = {}
    local ent = Entity(veh).state
    if not ent.stancer then
      stancer[plate].stancer = {}
      stancer[plate].plate = plate
      stancer[plate].online = true
      ent.stancer = stancer[plate]
      SaveStancer({plate = plate, setting = {}})
    end
  end
end

exports('AddStancerKit', function(vehicle)
  return AddStancerKit(vehicle)
end)

AddEventHandler('entityCreated', function(entity)
  local entity = entity
  Wait(4000)
  if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
    local plate = GetVehicleNumberPlateText(entity)
    if stancer[plate] and stancer[plate].stancer then
      local ent = Entity(entity).state
      ent.stancer = stancer[plate].stancer
      stancer[plate].online = true
    end
  end
end)

AddEventHandler('entityRemoved', function(entity)
  local entity = entity
  if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
    local ent = Entity(entity).state
    if ent.stancer then
      local plate = GetVehicleNumberPlateText(entity)
      stancer[plate].online = false
      stancer[plate].stancer = ent.stancer
      SaveStancer({plate = plate, setting = stancer[plate].stancer})
    end
  end
end)

RegisterNetEvent("renzu_stancer:addstancer") -- Standalone Purpose
AddEventHandler("renzu_stancer:addstancer", function(vehicle)
	AddStancerKit(vehicle)
end)

RegisterNetEvent("renzu_stancer:airsuspension")
AddEventHandler("renzu_stancer:airsuspension", function(entity,val,coords)
	TriggerClientEvent("renzu_stancer:airsuspension", -1, entity,val,coords)
end)
