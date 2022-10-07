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

RegisterNetEvent("renzu_stancer:airsuspension")
AddEventHandler("renzu_stancer:airsuspension", function(vehicle,val,coords)
	local v = NetToVeh(vehicle)
	CreateThread(function()
		Wait(math.random(1,500))
		if v ~= 0 and #(coords - GetEntityCoords(PlayerPedId())) < 50 and not busyplate[plate] then
			local plate = GetVehicleNumberPlateText(v)
			busyplate[plate] = true
			if vehiclesinarea[plate] ~= nil then
				vehiclesinarea[plate].wheeledit = true
			end
			playsound(GetEntityCoords(v),20,'suspension',1.0)
			local max = 0
			local data = {}
			local min = GetVehicleSuspensionHeight(v)
			local count = 0
			data.val = val
			local ent = Entity(v).state
			plate2 = tostring(GetVehicleNumberPlateText(v))
			veh_stats[plate2] = ent.stancer
			veh_stats[plate2].wheeledit = true
			veh_stats[plate2].heightdata = data.val
			ent:set('stancer', veh_stats[plate2], true)
			if (data.val * 100) < 15 then
				val = min
				data.val = data.val - 0.01
				local good = false
				count = 0
				while min > data.val and busyplate[plate] and count < 50 do
					SetVehicleSuspensionHeight(v,GetVehicleSuspensionHeight(v) - (1.0 * 0.01))
					min = GetVehicleSuspensionHeight(v)
					count = count + 1
					Citizen.Wait(100)
					good = true
				end
				--SetVehicleSuspensionHeight(v,data.val)
				count = 0
				while not good and min < data.val and busyplate[plate] and count < 50 do
					SetVehicleSuspensionHeight(v,GetVehicleSuspensionHeight(v) + (1.0 * 0.01))
					min = GetVehicleSuspensionHeight(v)
					count = count + 1
					Citizen.Wait(100)
				end
				SetVehicleSuspensionHeight(v,data.val)
			else
				val = min
				local good = false
				count = 0
				while min < data.val and busyplate[plate] and count < 50 do
					SetVehicleSuspensionHeight(v,GetVehicleSuspensionHeight(v) + (1.0 * 0.01))
					min = GetVehicleSuspensionHeight(v)
					count = count + 1
					Citizen.Wait(100)
					good = true
				end
				--SetVehicleSuspensionHeight(v,data.val)
				count = 0
				while not good and min > data.val and busyplate[plate] and count < 50 do
					SetVehicleSuspensionHeight(v,GetVehicleSuspensionHeight(v) - (1.0 * 0.01))
					count = count + 1
					min = GetVehicleSuspensionHeight(v)
					Citizen.Wait(100)
				end
				SetVehicleSuspensionHeight(v,data.val)
			end
			--TriggerServerEvent("renzu_hud:airsuspension_state",VehToNet(vehicle), true)
			busyplate[plate] = false
			busyairsus = false
		end
		return
	end)
end)

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
	vehicle = getveh()
    if vehicle ~= nil and vehicle ~= 0 and not busyairsus then
		busyairsus = true
		TriggerServerEvent("renzu_stancer:airsuspension",VehToNet(vehicle), data.val, GetEntityCoords(vehicle))
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
	for i = 0 , 1 do
		local k
		if i == 0 then k = '-0' else k = '0' end
		SetVehicleWheelYRotation(vehicle,i,tonumber(""..k.."."..val..""))
		wheelsettings[plate]['wheelrotationfront'][i] = tonumber(""..k.."."..val.."")
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
		SetWheelRotationFront(vehicle,val)
    end
	cb(true)
end)

function SetWheelRotationRear(vehicle, val)
	plate = tostring(GetVehicleNumberPlateText(vehicle))
	if wheelsettings[plate]['wheelrotationrear'] == nil then wheelsettings[plate]['wheelrotationrear'] = {} end
	for i = 2 , 3 do
		local k
		if i == 2 then k = '-0' else k = '0' end
		SetVehicleWheelYRotation(vehicle,i,tonumber(""..k.."."..val..""))
		wheelsettings[plate]['wheelrotationrear'][i] = tonumber(""..k.."."..val.."")
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
		SetWheelRotationRear(vehicle,val)
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

RegisterNetEvent("renzu_stancer:openstancer")
AddEventHandler("renzu_stancer:openstancer", function(vehicle,val,coords)
	OpenStancer()
end)

local Stancers = {}
local cachedata = {}
local cache = {}
AddStateBagChangeHandler('stancer' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(0)
	if not value then return end
    local net = tonumber(bagName:gsub('entity:', ''), 10)
    local vehicle = NetworkGetEntityFromNetworkId(net)
	local plate = GetVehicleNumberPlateText(vehicle)
	Stancers[plate] = vehicle
	SetVehicleSuspensionHeight(vehicle,value.height)
	SetStanceSetting(vehicle,value['wheelsetting'])
	SetVehicleWheelWidth(vehicle,tonumber(value['wheelsetting']['wheelwidth']))
	print('stancer')
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
				print('removed',plate)
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
	--SetVehicleWheelSize(v.entity,GetVehicleWheelSize(v.entity)) -- trick to avoid stance bug tricking the system or game that this is all visual only not physics maybe?
	SetVehicleWheelWidth(entity,tonumber(data['wheelwidth']))
	for i = 0 , 3 do
		if i <= 1 then
			SetVehicleWheelXOffset(entity,i,tonumber(data['wheeloffsetfront'][i]))
			SetVehicleWheelYRotation(entity,i,tonumber(data['wheelrotationfront'][i]))
		else
			SetVehicleWheelYRotation(entity,i,tonumber(data['wheelrotationrear'][i]))
			SetVehicleWheelXOffset(entity,i,tonumber(data['wheeloffsetrear'][i]))
		end
	end
end

CreateThread(function()
	Wait(1000)
	while true do
		local sleep = 1000
		for i = 1, #cache do
			local v = cache[i]
			local activate = v and not v.wheeledit and v.dist < 100
			local exist = DoesEntityExist(v.entity)
			if activate and exist then
				sleep = 1
				SetStanceSetting(v.entity,cache[i]['wheelsetting'])
			end
			if not exist then
				if vehiclesinarea[v.plate] then vehiclesinarea[v.plate] = nil end
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
	if wheelsettings[plate] == nil then wheelsettings[plate] = {} end
	if wheelsettings[plate]['wheeloffsetfront'] == nil then wheelsettings[plate]['wheeloffsetfront'] = {} end
	if wheelsettings[plate]['wheeloffsetrear'] == nil then wheelsettings[plate]['wheeloffsetrear'] = {} end
	if wheelsettings[plate]['wheelrotationfront'] == nil then wheelsettings[plate]['wheelrotationfront'] = {} end
	if wheelsettings[plate]['wheelrotationrear'] == nil then wheelsettings[plate]['wheelrotationrear'] = {} end

	for i = 0 , 3 do
		if i <= 1 then
			if wheelsettings[plate]['wheeloffsetfront'][i] == nil then
				wheelsettings[plate]['wheeloffsetfront'][i] = GetVehicleWheelXOffset(vehicle,i)
			end
			if wheelsettings[plate]['wheelrotationfront'][i] == nil then
				wheelsettings[plate]['wheelrotationfront'][i] = GetVehicleWheelYRotation(vehicle,i)
			end
		else
			if wheelsettings[plate]['wheeloffsetrear'][i] == nil then
				wheelsettings[plate]['wheeloffsetrear'][i] = GetVehicleWheelXOffset(vehicle,i)
			end
			if wheelsettings[plate]['wheelrotationrear'][i] == nil then
				wheelsettings[plate]['wheelrotationrear'][i] = GetVehicleWheelYRotation(vehicle,i)
			end
		end
	end
	if wheelsettings[plate]['wheelwidth'] == nil then
		wheelsettings[plate]['wheelwidth'] = tonumber(GetVehicleWheelWidth(vehicle))
	end
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
	vehicle = getveh()
	local ent = Entity(vehicle).state
	if Config.Framework == 'Standalone' and not ent.stancer then
		TriggerServerEvent('renzu_stancer:addstancer')
		while not ent.stancer do Wait(1) end
	end
	if busy or not ent.stancer then Notify('No Stancer Kit Install') return end
	local cache = ent.stancer
	isbusy = true
	vehicle  = getveh()
	if vehicle  ~= 0 and #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicle )) < 15 and GetVehicleDoorLockStatus(vehicle ) == 1 then
		carcontrol = not carcontrol
		cache.wheeledit = carcontrol
		ent:set('stancer', cache, true)
		local offset = {}
		local rotation = {}
		for i=0, 4 do
			offset[i] = GetVehicleWheelXOffset(vehicle,i)
			rotation[i] = GetVehicleWheelYRotation(vehicle,i)
		end
		SendNUIMessage({
			type = "show",
			content = {bool = carcontrol, offset = offset, rotation = rotation, height = ent.stancer.heightdata}
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