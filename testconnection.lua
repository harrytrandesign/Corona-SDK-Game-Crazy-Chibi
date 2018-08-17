---------------------------------------
-- Test connection to the internet
---------------------------------------
module(..., package.seeall)
local socket = require("socket") 

function test()           
	local connection = socket.tcp()
	connection:settimeout(1000)
	local result = connection:connect("www.google.com", 80)
	connection:close()
	if (result) then return true end
	return false
end