customnitro = {}
busyplate = {}
nearstancer = {}
busyairsus = false
wheelsettings = {}
wheeledit = false
isbusy = false
carcontrol = false
veh_stats = {}
local vehiclesinarea = {}

function getveh()
	local v = GetVehiclePedIsIn(PlayerPedId(), false)
	lastveh = GetVehiclePedIsIn(PlayerPedId(), true)
	local dis = -1
	if v == 0 then
		if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(lastveh)) < 5 then
			v = lastveh
		end
		dis = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(lastveh))
	end
	if dis > 3 then
		v = 0
	end
	if v == 0 then
		local count = 5
		v = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.000, 0, 70)
		while #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(v)) > 5 and count >= 0 do
			v = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.000, 0, 70)
			count = count - 1
			Wait(400)
		end
	end
	return tonumber(v)
end

RegisterNUICallback('setvehicleheight', function(data, cb)
	vehicle = GetVehiclePedIsIn(PlayerPedId())
    if vehicle ~= nil and vehicle ~= 0 then
		local ent = Entity(vehicle).state
		plate2 = tostring(GetVehicleNumberPlateText(vehicle))
		veh_stats[plate2] = ent.stancer
		veh_stats[plate2].wheeledit = true
		veh_stats[plate2].heightdata = data.val
		--ent:set('stancer', veh_stats[plate2], true)
		SetVehicleSuspensionHeight(vehicle,data.val)
    end
	cb(true)
end)

function SetWheelOffsetFront(vehicle, val)
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	if wheelsettings[plate]['wheeloffsetfront'] == nil then wheelsettings[plate]['wheeloffsetfront'] = {} end
	for i = 0 , 1 do
		local k
		if i == 0 then k = '-0' else k = '0' end
		SetVehicleWheelXOffset(vehicle,i,tonumber(""..k.."."..val..""))
		wheelsettings[plate]['wheeloffsetfront'][i] = tonumber(""..k.."."..val.."")
	end
	wheeledit = true
	if vehiclesinarea[plate] ~= nil then
		vehiclesinarea[plate].wheeledit = true
	end
end

exports('SetWheelOffsetFront', function(vehicle, val)
	return SetWheelOffsetFront(vehicle, val)
end)

RegisterNUICallback('setvehiclewheeloffsetfront', function(data, cb)
	vehicle = getveh()
	plate = tostring(GetVehicleNumberPlateText(vehicle))
    if vehicle ~= nil and vehicle ~= 0 then
		if wheelsettings[plate] == nil then wheelsettings[plate] = {} end
		local val = round(data.val * 100)
		SetWheelOffsetFront(vehicle, val)
    end
	cb(true)
end)

function SetWheelOffsetRear(vehicle, val)
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	if wheelsettings[plate]['wheeloffsetrear'] == nil then wheelsettings[plate]['wheeloffsetrear'] = {} end
	for i = 2 , 3 do
		local k
		if i == 2 then k = '-0' else k = '0' end
		SetVehicleWheelXOffset(vehicle,i,tonumber(""..k.."."..val..""))
		wheelsettings[plate]['wheeloffsetrear'][i] = tonumber(""..k.."."..val.."")
	end
	wheeledit = true
	if vehiclesinarea[plate] ~= nil then
		vehiclesinarea[plate].wheeledit = true
	end
end

exports('SetWheelOffsetRear', function(vehicle, val)
	return SetWheelOffsetRear(vehicle, val)
end)

RegisterNUICallback('setvehiclewheeloffsetrear', function(data, cb)
	vehicle = getveh()
	plate = tostring(GetVehicleNumberPlateText(vehicle))
    if vehicle ~= nil and vehicle ~= 0 then
		if wheelsettings[plate] == nil then wheelsettings[plate] = {} end
		local val = round(data.val * 100)
		SetWheelOffsetRear(vehicle,val)
    end
	cb(true)
end)

function SetWheelRotationFront(vehicle, val)
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	if wheelsettings[plate]['wheelrotationfront'] == nil then wheelsettings[plate]['wheelrotationfront'] = {} end
	SetVehicleHandlingFloat(vehicle, 'CCarHandlingData', 'fCamberFront', tonumber(val))
	for i = 0 , 1 do
		local k
		if i == 1 then k = '-0' else k = '0' end
		SetVehicleWheelXOffset(entity,i,GetVehicleWheelXOffset(vehicle,i))
		--SetVehicleWheelYRotation(vehicle,i,tonumber(""..k.."."..val..""))
		SetVehicleWheelYRotation(vehicle,i,GetVehicleWheelYRotation(vehicle,i))
		wheelsettings[plate]['wheelrotationfront'][i] = tonumber(val)
	end
	wheeledit = true
	if vehiclesinarea[plate] ~= nil then
		vehiclesinarea[plate].wheeledit = true
	end
end

exports('SetWheelRotationFront', function(vehicle, val)
	return SetWheelRotationFront(vehicle, val)
end)

RegisterNUICallback('setvehiclewheelrotationfront', function(data, cb)
	vehicle = getveh()
	plate = tostring(GetVehicleNumberPlateText(vehicle))
    if vehicle ~= nil and vehicle ~= 0 then
		if wheelsettings[plate] == nil then wheelsettings[plate] = {} end
		local val = round(data.val * 100)
		SetWheelRotationFront(vehicle,data.val)
		SetVehicleFixed(vehicle,true)
    end
	cb(true)
end)

function SetWheelRotationRear(vehicle, val)
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	if wheelsettings[plate]['wheelrotationrear'] == nil then wheelsettings[plate]['wheelrotationrear'] = {} end
	SetVehicleHandlingFloat(vehicle, 'CCarHandlingData', 'fCamberRear', tonumber(val))
	for i = 2 , 3 do
		local k
		if i == 3 then k = '-0' else k = '0' end
		--SetVehicleWheelYRotation(vehicle,i,tonumber(""..k.."."..val..""))
		SetVehicleWheelXOffset(entity,i,GetVehicleWheelXOffset(vehicle,i))
		SetVehicleWheelYRotation(vehicle,i,GetVehicleWheelYRotation(vehicle,i))
		wheelsettings[plate]['wheelrotationrear'][i] = tonumber(val)
	end

	wheeledit = true
	if vehiclesinarea[plate] ~= nil then
		vehiclesinarea[plate].wheeledit = true
	end
end

exports('SetWheelRotationRear', function(vehicle, val)
	return SetWheelRotationRear(vehicle, val)
end)

RegisterNUICallback('setvehiclewheelrotationrear', function(data, cb)
	vehicle = getveh()
	plate = tostring(GetVehicleNumberPlateText(vehicle))
    if vehicle ~= nil and vehicle ~= 0 then
		if wheelsettings[plate] == nil then wheelsettings[plate] = {} end
		local val = round(data.val * 100)
		SetWheelRotationRear(vehicle,data.val)
    end
	cb(true)
end)

RegisterNUICallback('setvehiclewheelwidth', function(data, cb)
	vehicle = getveh()
	plate = tostring(GetVehicleNumberPlateText(vehicle))
    if vehicle ~= nil and vehicle ~= 0 then
		if wheelsettings[plate] == nil then wheelsettings[plate] = {} end
		local val = tonumber(data.val)
		SetVehicleWheelWidth(vehicle,val)
		wheelsettings[plate]['wheelwidth'] = val
		wheeledit = true
		if vehiclesinarea[plate] ~= nil then
			vehiclesinarea[plate].wheeledit = true
		end
    end
	cb(true)
end)

RegisterNUICallback('setvehiclewheelsize', function(data, cb)
	vehicle = getveh()
	plate = tostring(GetVehicleNumberPlateText(vehicle))
    if vehicle ~= nil and vehicle ~= 0 then
		if wheelsettings[plate] == nil then wheelsettings[plate] = {} end
		local val = tonumber(data.val)
		SetVehicleWheelSize(vehicle,val)
		wheelsettings[plate]['wheelsize'] = val
		wheeledit = true
		if vehiclesinarea[plate] ~= nil then
			vehiclesinarea[plate].wheeledit = true
		end
    end
	cb(true)
end)

RegisterNetEvent("renzu_stancer:openstancer")
AddEventHandler("renzu_stancer:openstancer", function(vehicle,val,coords)
	OpenStancer()
end)

local Stancers = {}
local cachedata = {}
local cache = {}

local callbacks = {}
callback = function(name,...)
	callbacks[name] = promise:new()
	TriggerServerEvent('renzu_stancer:servercallback',name,...)
	return Citizen.Await(callbacks[name])
end

RegisterNetEvent('renzu_stancer:servercallback', function(name,data)
    callbacks[name]:resolve(data)
end)

AddEventHandler('gameEventTriggered', function (name, args) -- only game build >= 2189
	if name == 'CEventNetworkPlayerEnteredVehicle' then
		if args[1] == PlayerId() then
			local plate = GetVehicleNumberPlateText(args[2])
			local ent = Entity(args[2]).state
			local stancerdata = nil
			if not ent.stancer or ent.stancer and not vehiclesinarea[plate] then
				stancerdata = callback('stancers',plate)
			end
			if stancerdata and DoesEntityExist(args[2]) then
				stancerdata.r = GetGameTimer()
				print('setting stancer',stancerdata)
				ent:set('stancer', stancerdata, true)
			end
		end
	end
end)

AddStateBagChangeHandler('stancer' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(0)
	if not value or not value['wheelsetting'] then return end
    local vehicle = GetEntityFromStateBagName(bagName)
	if not DoesEntityExist(vehicle) then return end
	local plate = GetVehicleNumberPlateText(vehicle)
	Stancers[plate] = vehicle
	SetVehicleSuspensionHeight(vehicle,value.height)
	SetStanceSetting(vehicle,value['wheelsetting'])
	SetVehicleHandlingFloat(vehicle, 'CCarHandlingData', 'fCamberFront', value['wheelsetting']['wheelrotationfront']['0'])
	SetVehicleHandlingFloat(vehicle, 'CCarHandlingData', 'fCamberRear', value['wheelsetting']['wheelrotationrear']['2'])
	SetVehicleWheelWidth(vehicle,tonumber(value['wheelsetting']['wheelwidth']))
	SetVehicleWheelSize(vehicle,tonumber(value['wheelsetting']['wheelsize']))
	--SetReduceDriftVehicleSuspension(vehicle,true)
	--SetVehicleHandlingField(vehicle, 'CCarHandlingData', 'strAdvancedFlags', 0x8000+0x4000000)
	if vehiclesinarea[plate] == nil then vehiclesinarea[plate] = {} vehiclesinarea[plate]['plate'] = plate end
	vehiclesinarea[plate]['wheelsetting'] = value['wheelsetting']
	vehiclesinarea[plate]['speed'] = GetEntitySpeed(vehicle)
	vehiclesinarea[plate]['entity'] = vehicle
	vehiclesinarea[plate]['dist'] = #(GetEntityCoords(vehicle) - GetEntityCoords(PlayerPedId()))
	vehiclesinarea[plate]['wheeledit'] = value.wheeledit
	for k,v in pairs(vehiclesinarea) do
		table.insert(cachedata,v)
	end
	cache = cachedata
end)

local justseated = false
CreateThread(function()
	Wait(1000)
	while true do
		local ped = PlayerPedId()
		local coord = GetEntityCoords(ped)
		local c = 0
		cachedata = {}
		if not IsPedInAnyVehicle(ped) then justseated = false end
		for k,v in pairs(Stancers) do
			local ent = Entity(v).state
			local dist = #(GetEntityCoords(v) - coord)
			local plate = GetVehicleNumberPlateText(v)
			if DoesEntityExist(v) and dist < 100 and ent.stancer then
				if not ent.stancer.wheeledit and ent.stancer['wheelsetting'] then
					if vehiclesinarea[plate] == nil then vehiclesinarea[plate] = {} addtable = true vehiclesinarea[plate]['entity'] = v vehiclesinarea[plate]['plate'] = plate end
					vehiclesinarea[plate]['wheelsetting'] = ent.stancer['wheelsetting']
					vehiclesinarea[plate]['speed'] = GetEntitySpeed(v)
					vehiclesinarea[plate]['dist'] = dist
					vehiclesinarea[plate]['wheeledit'] = ent.stancer.wheeledit
					SetVehicleSuspensionHeight(v,ent.stancer.height)
					SetStanceSetting(v,ent.stancer['wheelsetting'])
					SetHeightProperly(v,ent)
				end
			elseif DoesEntityExist(v) and dist > 100 and ent.stancer and vehiclesinarea[plate] then
				vehiclesinarea[plate] = nil
			elseif not DoesEntityExist(v) then
				if vehiclesinarea[plate] then
					vehiclesinarea[plate] = nil
				end
				Stancers[k] = nil
			end
		end
		for k,v in pairs(vehiclesinarea) do
			table.insert(cachedata,v)
		end
		cache = cachedata
		Wait(2000)
	end
end)

SetHeightProperly = function(v,ent)
	if GetPedInVehicleSeat(v,-1) == PlayerPedId() and not justseated then
		justseated = true
		local c = 0
		while justseated and c < 400 do
			Wait(1)
			c = c + 1
			SetVehicleSuspensionHeight(v,ent.stancer.height)
		end
		SetVehicleSuspensionHeight(v,ent.stancer.height)
	end
end

SetStanceSetting = function(entity,data)
	SetVehicleWheelWidth(entity,tonumber(data['wheelwidth'] or 1.0) + 0.0)
	for i = 0 , 3 do
		if i <= 1 then
			SetVehicleWheelXOffset(entity,i,tonumber(data['wheeloffsetfront'][tostring(i)]))
			--SetVehicleWheelYRotation(entity,i,tonumber(data['wheelrotationfront'][i]))
		else
			--SetVehicleWheelYRotation(entity,i,tonumber(data['wheelrotationrear'][i]))
			SetVehicleWheelXOffset(entity,i,tonumber(data['wheeloffsetrear'][tostring(i)]))
		end
	end
end

CreateThread(function()
	Wait(1000)
	while true do
		local sleep = 1000
		for i = 1, #cache do
			local data = cache[i] or false
			local activate = data and not data.wheeledit and data.dist < 100
			local exist = data and DoesEntityExist(data.entity)
			if activate and exist then
				sleep = 0
				SetStanceSetting(data.entity,cache[i]['wheelsetting'])
			end
			if not exist and data then
				if vehiclesinarea[data.plate] then vehiclesinarea[data.plate] = nil end
				if cachedata[i] then cachedata[i] = nil end
			end
		end
		Wait(sleep)
	end
	return
end)

RegisterNUICallback('wheelsetting', function(data, cb)
	vehicle = GetVehiclePedIsIn(PlayerPedId(),false)
	wheeledit = false
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	if veh_stats[plate] == nil then veh_stats[plate] = {} end
	if veh_stats[plate]['wheelsetting'] == nil then veh_stats[plate]['wheelsetting'] = {} end
	local vehicle_height = GetVehicleSuspensionHeight(vehicle)
	wheelsettings[plate] = {}
	if wheelsettings[plate]['wheeloffsetfront'] == nil then wheelsettings[plate]['wheeloffsetfront'] = {} end
	if wheelsettings[plate]['wheeloffsetrear'] == nil then wheelsettings[plate]['wheeloffsetrear'] = {} end
	if wheelsettings[plate]['wheelrotationfront'] == nil then wheelsettings[plate]['wheelrotationfront'] = {} end
	if wheelsettings[plate]['wheelrotationrear'] == nil then wheelsettings[plate]['wheelrotationrear'] = {} end

	for i = 0 , 3 do
		if i <= 1 then
			if wheelsettings[plate]['wheeloffsetfront'][tonumber(i)] then wheelsettings[plate]['wheeloffsetfront'][tonumber(i)] = nil end

			wheelsettings[plate]['wheeloffsetfront'][tostring(i)] = GetVehicleWheelXOffset(vehicle,i)
			
			if wheelsettings[plate]['wheelrotationfront'][tonumber(i)] then wheelsettings[plate]['wheelrotationfront'][tonumber(i)] = nil end

			wheelsettings[plate]['wheelrotationfront'][tostring(i)] =  GetVehicleHandlingFloat(vehicle, 'CCarHandlingData', 'fCamberFront') --GetVehicleWheelYRotation(vehicle,i)
		else
			if wheelsettings[plate]['wheeloffsetrear'][tonumber(i)] then wheelsettings[plate]['wheeloffsetrear'][tonumber(i)] = nil end

			wheelsettings[plate]['wheeloffsetrear'][tostring(i)] = GetVehicleWheelXOffset(vehicle,i)

			if wheelsettings[plate]['wheelrotationrear'][tonumber(i)] then wheelsettings[plate]['wheelrotationrear'][tonumber(i)] = nil end

			wheelsettings[plate]['wheelrotationrear'][tostring(i)] = GetVehicleHandlingFloat(vehicle, 'CCarHandlingData', 'fCamberRear') -- GetVehicleWheelYRotation(vehicle,i)
		end
	end
	wheelsettings[plate]['wheelwidth'] = tonumber(GetVehicleWheelWidth(vehicle))

	wheelsettings[plate]['wheelsize'] = tonumber(GetVehicleWheelSize(vehicle))

	veh_stats[plate]['wheelsetting'] = wheelsettings[plate]

	veh_stats[plate].height = vehicle_height
	
    if vehicle ~= nil and vehicle ~= 0 then
		local ent = Entity(vehicle).state
		veh_stats[plate].wheeledit = false
		veh_stats[plate].heightdata = ent.stancer.heightdata
		ent:set('stancer', veh_stats[plate], true)
		TriggerServerEvent('renzu_stancer:save',veh_stats[plate])
		Notify('Vehicle Wheel Data is Saved')
	end
	cb(true)
end)


RegisterCommand(Config.commands, function()
	OpenStancer()
end, false)

CreateThread(function()
	RegisterKeyMapping(Config.commands, 'Open Car Control', 'keyboard', Config.keybinds)
	return
end)

RegisterNUICallback('closecarcontrol', function(data, cb)
	carcontrol = false
	SendNUIMessage({
		type = "show",
		content = {bool = false}
	})
	SetNuiFocus(false,false)
	cb(true)
end)

function Notify(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end

function OpenStancer()
	vehicle = GetVehiclePedIsIn(PlayerPedId(),false)
	if not DoesEntityExist(vehicle) then return end
	local ent = Entity(vehicle).state
	if Config.Framework == 'Standalone' and not ent.stancer then
		TriggerServerEvent('renzu_stancer:addstancer')
		while not ent.stancer do Wait(1) end
	end
	if busy or not ent.stancer then Notify('No Stancer Kit Install') return end
	local cache = ent.stancer
	--SetReduceDriftVehicleSuspension(vehicle,true)
	--SetVehicleHandlingField(vehicle, 'CCarHandlingData', 'strAdvancedFlags', 0x8000+0x4000000)
	isbusy = true
	if vehicle  ~= 0 and #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicle )) < 15 and GetVehicleDoorLockStatus(vehicle ) == 1 then
		carcontrol = not carcontrol
		cache.wheeledit = carcontrol
		ent:set('stancer', cache, true)
		local offset = {}
		local rotation = {}
		for i=0, 4 do
			offset[i] = GetVehicleWheelXOffset(vehicle,i)
		end
		SendNUIMessage({
			type = "show",
			content = {bool = carcontrol, offset = offset, rotation = {
				rear = GetVehicleHandlingFloat(vehicle, 'CCarHandlingData', 'fCamberRear'),
				front = GetVehicleHandlingFloat(vehicle, 'CCarHandlingData', 'fCamberFront')
			}, 
			height = GetVehicleSuspensionHeight(vehicle),
			width = GetVehicleWheelWidth(vehicle),
			size = GetVehicleWheelSize(vehicle)
			}
		})
		Wait(500)
		SetNuiFocus(carcontrol,carcontrol)
		SetNuiFocusKeepInput(true)
		isbusy = false
		CreateThread(function()
			while carcontrol do
				whileinput()
				Wait(5)
			end
			SetNuiFocusKeepInput(false)
			return
		end)
	else
		if GetVehicleDoorLockStatus(vehicle ) ~= 1 then
			Notify("No Unlock Vehicle Nearby")
		else
			Notify("No Nearby Vehicle")
		end
	end
end

exports('OpenStancer', function()
	return OpenStancer()
end)

function whileinput()
	if Config.FixedCamera then
		DisableControlAction(1, 1, true)
		DisableControlAction(1, 2, true)
	end
	DisableControlAction(1, 18, true)
	DisableControlAction(1, 68, true)
	DisableControlAction(1, 69, true)
	DisableControlAction(1, 70, true)
	DisableControlAction(1, 91, true)
	DisableControlAction(1, 92, true)
	DisableControlAction(1, 24, true)
	DisableControlAction(1, 25, true)
	DisableControlAction(1, 14, true)
	DisableControlAction(1, 15, true)
	DisableControlAction(1, 16, true)
	DisableControlAction(1, 17, true)
	DisablePlayerFiring(PlayerId(), true)
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5)
end

function playsound(vehicle,max,file,maxvol)
	local volume = maxvol
	local mycoord = GetEntityCoords(PlayerPedId())
	local distIs  = tonumber(string.format("%.1f", #(mycoord - vehicle)))
	if (distIs <= max) then
		distPerc = distIs / max
		volume = (1-distPerc) * maxvol
		local table = {
			['file'] = file,
			['volume'] = volume
		}
		SendNUIMessage({
			type = "playsound",
			content = table
		})
	end
end