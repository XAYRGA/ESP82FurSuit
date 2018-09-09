print("XWLN Network SVC -- Init.")
if srv then 
	srv:close()
end 
CSRObjects = {}
dofile("fsmap.lua") -- Load the filesystem map
dofile("wificonf.lua")  -- Starts the access point 
dofile("dens.lua") -- start the DNS service. 





local ClientSessionRequest = { -- template for handling multiple requests. 
	payload = "",
	handle = NULL,
	byte = 0, 
	client = NULL, 
	size = 0 
}

TYPE_FILE = 1  -- defined twice? 
TYPE_STATIC = 2 

local rate = 16  -- how many bytes to read at once. 
local max = 16  -- how many bytes to send at once. 
local function sendCSRRoutine(self,csr) 
	local sendbuffer = "" 
	local i = 0 
	local conn = csr.client 
	local fobj = csr.handle 
	local fname = csr.data 
	
	print("ClientSessionRequest OPEN " ,conn,fname, " arena size " , rate * max)
	-- local c_csr = {birth = tmr.now(), lastsend = tmr.now(), fail = 0}  -- 
	-- CSRObjects[csr] = c_csr deprecated. 
	while (csr.byte < csr.size) do  -- keep going until the data is fufilled. 
	
		i = i + 1  -- advance byte
		csr.byte = csr.byte + rate -- advance our rate. 
		
	
		sendbuffer = sendbuffer .. fobj:read(rate) -- read the specified amount. 
		if i == max then  -- once we've loaded our message, send the buffer. 
			print(string.sub(tostring(conn),10),"push",csr.byte)
			i = 0 -- reset our counter 
			
			conn:send(sendbuffer,function()  -- send the message, callback once it's sent. 
				
				sendbuffer = ""  -- clear the send queue. 
				--c_csr.lastsend = tmr.now() -- update when we last sent.  deprecated
				coroutine.resume(self) -- after we've confirmed it's sent. We can resume the coroutine. 
				
			end) 
			
			coroutine.yield(self) -- stop coroutine. 
			
		end 
		
		
	
	end 
	if #sendbuffer > 0 then  -- We've exceeded our size, but there is still data left to send. 
			conn:send(sendbuffer,function()  -- so send it 
				
				sendbuffer = ""  -- clear the buffer. 
				print("ClientSessionRequest CLOSE " ,conn,fname) 
				conn:close() -- and close the connection. 

			end) 
	
	else 
		print("ClientSessionRequest CLOSE2 " ,conn,fname)
		conn:close()  -- we don't have anything to send, so just close it. 
		
		
		
	end 
	-- CSRObjects[csr] = nil deprecated. 

end 



local function handleClientRequest(conn,req) 

	local CSR = {} -- create new CSR 
	
	for k,v in pairs(ClientSessionRequest) do  -- copy the CSR template table. 
			CSR[k] = v
	end 
		
	CSR.client = conn -- pass socket object to CSR 
	
	local data = LUT[req] -- get file configuration 
	
	if data==nil then  -- we got nothing from our file table, return a very crude 404. 
		conn:send("404 " .. req,function()  -- send it .
			conn:close()  -- close connection 
		end) 
		
	elseif data[1]==TYPE_STATIC then  -- i don't think this works.
		conn:send(data[2],function() 
			conn:close() 
		end) 	
	elseif data[1]==TYPE_FILE then  -- check file type. 
	
		CSR.size = file.stat(data[2]).size  -- get file data size. 
		CSR.handle = file.open(data[2],"r")  -- open a reader on it. 
		CSR.data = data[2] -- copy file data. 
		
		local csr = coroutine.create(sendCSRRoutine)  -- start coroutine 
		coroutine.resume(csr,csr,CSR)  -- push start command 
	end 
	


end 


-- a simple http server
srv=net.createServer(net.TCP)  -- start a TCP server 
srv:listen(80,function(conn)  --  listen on port 80
    conn:on("receive",function(conn,payload) -- on receive 
	
		local rqsl =  string.find(payload, "\n",0,true) -- Separate requerst lines.
		
		local req_line = string.sub(payload,0,rqsl)
		
		
		
		local rqdx =  string.find(req_line, "HTTP/1.1",0,true) -- find end of request. 
		
		if rqdx==nil then -- we didn't find http 1.1
			conn:send("Only http 1.1 supported." ,function() 
				conn:close()  -- kill it. 
			end) 
		end 
		
		local req = string.sub(req_line,5,rqdx - 2) -- get the request url. 
		print(req)
		handleClientRequest(conn,req) -- handle it .
    end) 
end)
print("[OK] ----HTTP ")     
