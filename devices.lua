local devices_module = {};
local http = require "socket.http";
JSON = assert(loadfile "JSON.lua")() -- one-time load of the routines

function DevicesScenes(DeviceType, qualifier)
	local response = "", ItemNumber, result, decoded_response, record, k;
        print(qualifier)
   	if qualifier ~= nil then   
      		response = 'All '..DeviceType..' starting with '..qualifier
		quallength = string.len(qualifier)
   	else
      		response = 'All available '..DeviceType
   	end
   	decoded_response = device_list(DeviceType)
        result = decoded_response["result"]
	StoredType = DeviceType
   	StoredList = {}
        ItemNumber = 0
        for k,record in pairs(result) do
                if type(record) == "table" then
			DeviceName = record['Name']
       			-- Don't bother to store Unknown devices
       			if DeviceName ~= "Unknown" then 
			   	if qualifier ~= nil then   
                                        if qualifier == string.sub(DeviceName,1,quallength) then
	       		   			ItemNumber = ItemNumber + 1
        	  				table.insert(StoredList, DeviceName)
					end
   				else
	          			ItemNumber = ItemNumber + 1
        	  			table.insert(StoredList, DeviceName)
				end
       			end
                end
        end
   	table.sort(StoredList)
   	for ItemNumber,DeviceName in ipairs(StoredList) do
      		response = response..'\n'..ItemNumber..' - '..StoredList[ItemNumber]
   	end
	return response
end

function devices_module.handler(parsed_cli)
	local response = ""
        response = DevicesScenes(parsed_cli[2],parsed_cli[3])
	return status, response;
end

local devices_commands = {
			["devices"] = {handler=devices_module.handler, description="devices - devices - return list of all devices\ndevices - devices qualifier - all that start with qualifier i.e.\n devices St - all devices that start with St"},
			["scenes"] = {handler=devices_module.handler, description="scenes - scenes - return list of all scenes\ndevices - devices qualifier - all that start with qualifier i.e.\n scenes down - all scenes that start with down"}
		      }

function devices_module.get_commands()
	return devices_commands;
end

return devices_module;
