

ESX = nil
QBCore = nil
RegisterUsableItem = nil
Initialized()
stancer = {}

Citizen.CreateThread(function()
  Wait(1000)
  --DeleteResourceKvp('stancer')
  local ret = json.decode(GetResourceKvpString('stancer') or '[]') or {}
  for k,v in pairs(ret) do
    if stancer[v.plate] == nil then stancer[v.plate] = {} end
    stancer[v.plate].plate = v.plate
    stancer[v.plate].stancer = v.setting
    stancer[v.plate].online = false
  end

  for k,v in ipairs(GetAllVehicles()) do
    local plate = GetVehicleNumberPlateText(v)
    if stancer[plate] and plate == stancer[plate].plate then
      if stancer[plate].stancer then
        local ent = Entity(v).state
        local data = ReformatStancer(stancer[plate].stancer)
        ent:set('stancer', data, true)
        ent:set('online', true, true)
      end
    end
  end
end)

ReformatStancer = function(stancer)
  local data = {}
  for k,v in pairs(stancer) do
    if k == 'wheelsetting' then
      for k1,v in pairs(v) do
        if type(v) == 'table' then
          for k2,v in pairs(v) do
            if data[k] == nil then data[k] = {} end
            if data[k][k1] == nil then data[k][k1] = {} end
            data[k][k1][tonumber(k2)] = v
          end
        elseif k and k1 then
          if data[k] == nil then data[k] = {} end
          if data[k][k1] == nil then data[k][k1] = {} end
          data[k][k1] = v
        end
      end
    elseif k then
      data[k] = v
    end
  end
  return data
end

function SaveStancer(ob)
    local plate = ob.plate
    local data = json.decode(GetResourceKvpString('stancer') or '[]') or {}
    local result = data[plate]
    if result == nil then
      data[plate] = {plate = ob.plate, setting = ob.setting}
      SetResourceKvp('stancer',json.encode(data))
    elseif result then
        data[plate] = {plate = ob.plate, setting = ob.setting}
        SetResourceKvp('stancer',json.encode(data))
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

local servervehicles = {}
AddEventHandler('entityCreated', function(entity)
  local entity = entity
  Wait(1000)
  if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
    local plate = GetVehicleNumberPlateText(entity)
    if stancer[plate] and stancer[plate].stancer then
      local ent = Entity(entity).state
      ent.stancer = ReformatStancer(stancer[plate].stancer)
      stancer[plate].online = true
      if servervehicles[plate] and DoesEntityExist(NetworkGetEntityFromNetworkId(servervehicles[plate])) and GetEntityType(NetworkGetEntityFromNetworkId(servervehicles[plate])) == 2 and servervehicles[GetVehicleNumberPlateText(NetworkGetEntityFromNetworkId(servervehicles[plate]))] then
        DeleteEntity(NetworkGetEntityFromNetworkId(servervehicles[plate])) -- delete duplicate vehicle with the same plate wandering in the server
      end
    end
    servervehicles[plate] = NetworkGetNetworkIdFromEntity(entity)
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

RegisterNetEvent("renzu_stancer:save")
AddEventHandler("renzu_stancer:save", function(stance)
  local vehicle = GetVehiclePedIsIn(GetPlayerPed(source),false)
  local ent = Entity(vehicle).state
  if ent.stancer then
    local plate = GetVehicleNumberPlateText(vehicle)
    local data = json.decode(GetResourceKvpString('stancer') or '[]') or {}
    if not stancer[plate] then stancer[plate] = {} end
    stancer[plate].stancer = stance
    data[plate] = {plate = plate, setting = stance}
    SetResourceKvp('stancer',json.encode(data))
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
