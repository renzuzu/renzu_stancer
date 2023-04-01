ESX = nil
QBCore = nil
RegisterUsableItem = nil
Initialized()
local stancer = {}


local sql = setmetatable({},{
	__call = function(self)

		self.insert = function(plate,...)
			local str = 'INSERT INTO %s (%s, %s) VALUES(?, ?)'
			return MySQL.insert.await(str:format('renzu_stancer','plate','setting'),{plate,...})
		end

		self.save = function(string, data)
			local str = 'UPDATE %s SET setting = ? WHERE %s = ?'
			local isExist = self.query(string)
			if isExist[1] then
				return MySQL.update(str:format('renzu_stancer','plate'),{data,string})
			else
				return self.insert(string,data)
			end
		end

		self.query = function(string)
			local str = 'SELECT * FROM %s WHERE %s = ?'
			return MySQL.query.await(str:format('renzu_stancer','plate'),{string})
		end

        self.fetch = function()
            return MySQL.query.await('SELECT * FROM renzu_stancer')
        end

		return self
	end
})

local db = sql()

Citizen.CreateThreadNow(function()
	local success, result = pcall(MySQL.scalar.await, 'SELECT 1 FROM renzu_stancer')

	if not success then
		MySQL.query.await([[CREATE TABLE `renzu_stancer` (
			`plate` varchar(128) NOT NULL,
			`setting` longtext DEFAULT NULL
		)]])
		print("^2SQL INSTALL SUCCESSFULLY ^0")
	end

	local backup = GetResourceKvpString('stancer')

	if backup then
		local data = json.decode(backup)
        for plate,v in pairs(data) do
            if v.setting.wheelsetting then
                stancer[plate] = v.setting.wheelsetting
            end
        end
	end

    local fetch = db.fetch()

    for k,v in pairs(fetch) do
        stancer[v.plate] = json.decode(v.setting)
    end

    for k, vehicle in ipairs(GetAllVehicles()) do
        local plate = GetVehicleNumberPlateText(vehicle)
        if stancer[plate] then 
            Entity(vehicle).state:set('stancer', stancer[plate], true)
            Wait(0)
        end
    end
end)

function SaveStancer(data)
    local result = db.query(data.plate)
    if result[1] == nil then
        db.save(plate,json.encode(data.setting))
    elseif result[1] then
        db.save(plate,json.encode(data.setting))
    end
end

function firstToUpper(str) return (str:gsub("^%l", string.upper)) end

Citizen.CreateThread(function()
    if Config.Framework ~= 'Standalone' then
        for k, v in pairs(Config.items) do
            local stanceritem = string.lower(v)
            RegisterUsableItem(stanceritem, function(source)
                local xPlayer = GetPlayerFromId(source)
                local veh = GetVehiclePedIsIn(GetPlayerPed(source), false)
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
    if veh == nil then veh = GetVehiclePedIsIn(GetPlayerPed(source), false) end
    local plate = GetVehicleNumberPlateText(veh)
    print("ADD")
    if not stancer[plate] then
        stancer[plate] = {}
        local ent = Entity(veh).state
        if not ent.stancer then
            ent:set('stancer',{},true)
            db.save(plate,'[]')
        end
    end
end

exports('AddStancerKit', function(vehicle) return AddStancerKit(vehicle) end)

local servervehicles = {}

local callbacks = {}
registercallback = function(name,cb) -- create callbacks. so we wont have much convertion for other frameworks
	callbacks[name] = cb
end

RegisterNetEvent('renzu_stancer:servercallback', function(name,...)
    local source = source
    TriggerClientEvent('renzu_stancer:servercallback',source,name,callbacks[name](source,...))
end)

registercallback('stancers', function(source,plate)
	local plate = plate
	return stancer[plate]
end)

SetStancer = function(entity)
    if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
        local plate = GetVehicleNumberPlateText(entity)
        if stancer[plate] then
            Entity(entity).state:set('stancer',stancer[plate],true)
        end
    end
end

AddStateBagChangeHandler('VehicleProperties' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
	Wait(0)
	local net = tonumber(bagName:gsub('entity:', ''), 10)
	if not value then return end
    local entity = NetworkGetEntityFromNetworkId(net)
    Wait(1000)
    if DoesEntityExist(entity) then
        SetStancer(entity) -- compatibility with ESX onesync server setter vehicle spawn
    end
end)

AddEventHandler('entityCreated', function(entity)
    local entity = entity
    Wait(1000)
    SetStancer(entity)
end)

AddEventHandler('entityRemoved', function(entity)
    local entity = entity
    if DoesEntityExist(entity) and GetEntityPopulationType(entity) == 7 and GetEntityType(entity) == 2 then
        local ent = Entity(entity).state
        if ent.stancer then
            local plate = GetVehicleNumberPlateText(entity)
            db.save(plate,json.encode(ent.stancer))
        end
    end
end)

RegisterNetEvent("renzu_stancer:save")
AddEventHandler("renzu_stancer:save", function(stance)
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(source), false)
    local ent = Entity(vehicle).state
    if ent.stancer then
        local plate = GetVehicleNumberPlateText(vehicle)
        if not stancer[plate] then stancer[plate] = {} end
        stancer[plate] = stance
        db.save(plate,json.encode(ent.stancer))
    end
end)

RegisterNetEvent("renzu_stancer:addstancer") -- Standalone Purpose
AddEventHandler("renzu_stancer:addstancer",function(vehicle) 
    AddStancerKit(vehicle) 
end)