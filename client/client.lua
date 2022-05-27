local town_hash = false
local district_hash = false
local state_hash = false
local print_hash = false
local written_hash = false

local characterselected = false

RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function(charid)
	Wait(1000)
	characterselected = true
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3000)
		local player = PlayerPedId()
		local x, y, z = table.unpack(GetEntityCoords(player))
		local temptown = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, 1)
		local tempdistrict = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, 10)
		local tempstate = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, 0)

		local tempprint =  Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, 12)
		local tempwritten =  Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, 13)

		
		local changed = false
		
		if (tempprint ~= print_hash) then
			-- Town has changed
			print_hash = tempprint
			changed = true
		end

		if (tempwritten ~= written_hash) then
			-- Town has changed
			written_hash = tempwritten
			changed = true
		end

		if (tempstate ~= state_hash) then
			-- Town has changed
			state_hash = tempstate
			changed = true
		end

		if (temptown ~= town_hash) then
			-- Town has changed
			town_hash = temptown
			changed = true
		end

		if (tempdistrict ~= district_hash) then
			-- Town has changed
			district_hash = tempdistrict
			changed = true
		end
		if changed == true and characterselected == true then
			alertTop() 
		end
	end
end)

function GetCardinalDirection(h)
	if h <= 22.5 then
		return "N"
	elseif h <= 67.5 then
		return "NE"
	elseif h <= 112.5 then
		return "E"
	elseif h <= 157.5 then
		return "SE"
	elseif h <= 202.5 then
		return "S"
	elseif h <= 247.5 then
		return "SW"
	elseif h <= 292.5 then
		return "W"
	elseif h <= 337.5 then
		return "NW"
	else
		return "N"
	end
end

function getMapData(hash)
	if hash ~= false then
		local sd = Config.MapData[hash]

		if sd then
			return sd.ZoneName
		else
			return "Unknown"
		end
	else
		return "Unknown"
	end
end

function alertTop() 	
	local district = "Unknown"
	local town = "Unknown"
	local state = "Unknown"
	local printed = "Unknown"
	local written = "Unknown"

	district = getMapData(district_hash)
	town = getMapData(town_hash)
	state = getMapData(state_hash)
	printed = getMapData(print_hash)
	written = getMapData(written_hash)

	local hour =  GetClockHours()
	local ap = 'am'

	if hour > 12 then
		hour = hour  - 12
		ap = 'pm'
	elseif hour == 0 then
		hour = hour + 12
		ap = 'am'
	elseif hour == 12 then
		ap = 'pm'
	end

	if hour < 10 then
		hour = '0'..hour
	end

	local metric = ShouldUseMetricTemperature();
	local temperature
	local temperatureUnit
	local windSpeed
	local windSpeedUnit
	if metric then
		temperature = math.floor(GetTemperatureAtCoords(x, y, z))
		temperatureUnit = 'C'

		windSpeed = math.floor(GetWindSpeed())
		windSpeedUnit = 'kph'
	else
		temperature = math.floor(GetTemperatureAtCoords(x, y, z) * 9/5 + 32)
		temperatureUnit = 'F'

		windSpeed = math.floor(GetWindSpeed() * 0.621371)
		windSpeedUnit = 'mph'
	end

	local wx, wy, wz = table.unpack(GetWindDirection())

	local tempStr = string.format('%d °%s', temperature, temperatureUnit)
	-- local windStr = string.format('%d %s %s', windSpeed, windSpeedUnit, GetCardinalDirection(wx))

	local time = hour ..":" .. GetClockMinutes() ..":" .. GetClockSeconds() .. ap

	-- TriggerEvent("vorp:NotifyTop",  'tbd', location, 4000)
	SendNUIMessage({
		type = 'openzone',
		district = district,
		town = town,
		time = time,
		temp = tempStr,
		state = state,
		written = written,
		printed = printed
	})
end



RegisterCommand("zoneinfo", function(source, args, rawCommand) --  COMMAND
	characterselected = true
	alertTop()
end)

