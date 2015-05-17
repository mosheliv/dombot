local battery_module = {};
local http = require "socket.http";
JSON = assert(loadfile "JSON.lua")() -- one-time load of the routines

function get_battery_level(DeviceName)
   	idx = idx_from_name(DeviceName,'devices')
   	-- Determine battery level
        t = server_url.."/json.htm?type=devices&rid=" .. idx
        print ("JSON request <"..t..">");
        jresponse, status = http.request(t)
        decoded_response = JSON:decode(jresponse)
        result = decoded_response["result"]
        record = result[1]
	BattLevel = record["BatteryLevel"]
	LastUpdate = record["LastUpdate"]
        DeviceName = record["Name"]
	return DeviceName, BattLevel, LastUpdate;
end

function battery(DeviceName)
	local response = ""
        DeviceName, BattLevel, LastUpdate = get_battery_level(DeviceName)
   	print(DeviceName .. ' batterylevel is ' .. BattLevel .. "%")
   	response = DeviceName..' battery level was '..BattLevel..'% when last seen '..LastUpdate
	return status, response;
end

function battery_module.handler(parsed_cli)
        local t, jresponse, status, decoded_response
	if parsed_cli[2] == 'battery' then
	 	DeviceName = form_device_name(parsed_cli)
		status, response = battery(DeviceName)
	else
		-- Get list of all user variables
        	t = server_url.."/json.htm?type=command&param=getuservariables"
--        	t = server_url.."/json.htm?type=devices"
        	print ("JSON request <"..t..">");  
        	jresponse, status = http.request(t)
	        decoded_response = JSON:decode(jresponse)
        	result = decoded_response["result"]
		if result == nil then
			return "not found", "No Battery devices were found, master"
		end

		for k,record in pairs(result) do
			if type(record) == "table" then
				if record['Name'] == 'DevicesWithBatteries' then
					print(record['idx'])
					idx = record['idx']
				end
			end
		end
		
		-- Get user variable DevicesWithBatteries
        	t = server_url.."/json.htm?type=command&param=getuservariable&idx="..idx
        	print ("JSON request <"..t..">");  
        	jresponse, status = http.request(t)
        	decoded_response = JSON:decode(jresponse)
        	result = decoded_response["result"]
		record = result[1]
		DevicesWithBatteries = record["Value"]
   		DeviceNames = {}
   		print(DevicesWithBatteries)
   		for DeviceName in string.gmatch(DevicesWithBatteries, "[^|]+") do
      			DeviceNames[#DeviceNames + 1] = DeviceName
   		end
	  	-- Loop round each of the devices with batteries
		response = ''
   		for i,DeviceName in ipairs(DeviceNames) do
                	status, r = battery(DeviceName)
			response = response .. r .. '\n'
		end
	end
	return status, response
end

local battery_commands = {
			["battery"] = {handler=battery_module.handler, description="battery - battery devicename - returns battery level of devicename and when last updated"},
			["batteries"] = {handler=battery_module.handler, description="batteries - batteries - returns battery level of DevicesWithBatteries and when last updated"}
		      }

function battery_module.get_commands()
	return battery_commands;
end

return battery_module;
