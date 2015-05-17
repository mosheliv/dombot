local commands = {};

-- Load the verse XMPP library
require "verse".init("client");
-- Load the configuration file
local config = assert(loadfile "bot.cfg" )();

c = verse.new();
c:add_plugin("version");
c:add_plugin("disco");

-- dumps device record in readable form

function list_device_attr(dev, mode)
	local result = "";
	local exclude_flag;

	-- Don't dump these fields as they are boring. Name data and idx arrear anyway to exclude them
	
	local exclude_fields = {"Name", "Data", "idx", "SignalLevel", "CustomImage", "Favorite", "HardwareID", "HardwareName", "HaveDimmer", "HaveGroupCmd", "HaveTimeout", "Image", "IsSubDevice", "Notifications", "PlanID", "Protected", "ShowNotifications", "StrParam1", "StrParam2", "SubType", "SwitchType", "SwitchTypeVal", "Timers", "TypeImg", "Unit", "Used", "UsedByCamera", "XOffset", "YOffset"};

	result = "<"..dev.Name..">, Data: "..dev.Data..", Idx: ".. dev.idx;

	if mode == "full" then
		for k,v in pairs(dev) do
			exclude_flag = 0;
			for i, k1 in ipairs(exclude_fields) do
				if k1 == k then
					exclude_flag = 1;
					break;
				end
			end
			if exclude_flag == 0 then
				result = result..k.."="..tostring(v)..", ";
			else
				exclude_flag = 0;
			end
		end
	end
	return result;
end


-- prints short help

function help_handler(parsed_cli)
	local response = "";

	for k, r in pairs(commands) do 
		if r.description then
			print(k, r.description);
			response = response..string.format("<%s>:%s\n",k, r.description);
		end
	end
	print ("help response", response)
	return 1, response;
end

commands = {
			["help"] = {handler=help_handler, description=nil}
		};


-- Load the modules that handle the commands. each module can have more than one command associated with it (see the list example)
print("Loading command modules...")
for i, m in ipairs(command_modules) do
	print("Loading module <"..m..">");
	t = assert(loadfile(m..".lua"))();
	cl = t:get_commands();
	for c, r in pairs(cl) do
		print("found command <"..c..">");
		commands[c] = r;
		print(commands[c].handler);
	end
end


-- Add some hooks for debugging
c:hook("opened", function () print("Stream opened!") end);
c:hook("closed", function () print("Stream closed!") end);
c:hook("stanza", function (stanza) 
	local body = stanza:get_child("body");
	print("Stanza:", stanza) 
end);

-- This one prints all received data
c:hook("incoming-raw", print, 1000);

-- Print a message after authentication
c:hook("authentication-success", function () print("Logged in!"); end);
c:hook("authentication-failure", function (err) print("Failed to log in! Error: "..tostring(err.condition)); end);

-- Print a message and exit when disconnected
c:hook("disconnected", function () print("Disconnected!"); os.exit(); end);

-- Now, actually start the connection:
c:connect_client(jid, password);

-- Catch the "ready" event to know when the stream is ready to use
c:hook("ready", function ()
	print("Stream ready!");
	c.version:set{ name = "verse example client" };
	c:send(verse.presence():add_child(c:caps()));
	c:query_version(c.jid, function (v) print("I am using "..(v.name or "<unknown>")); end);
-- Hook the messages once stream is ready 
        c:hook("message", function (message)
                local body = message:get_child_text("body");
		local command_dispatch, status;
                if not body or message.attr.type == "error" then
                        return;
                end

		--- parse the command
		local parsed_command = {}
		for w in string.gfind(body, "(%w+)") do
			table.insert(parsed_command, w)
		end
		--- check for passcode and execute
		if passcode == nil  or parsed_command[1] == passcode then
			c:send(verse.message({type = "chat", to = message.attr.from}, "Hello, master! got command <"..parsed_command[2]..">"));
			command_dispatch = commands[parsed_command[2]];
			if command_dispatch then
				status, text = command_dispatch.handler(parsed_command);
			else
				text = "command <"..parsed_command[2].."> not cound, master";
			end
			c:send(verse.message({type = "chat", to = message.attr.from}, text));

				
		end
        end);
end);


print("Starting loop...")
verse.loop()
