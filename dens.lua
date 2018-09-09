--  NOT MY CODE. Couldnt find the source of it.
-- This controls the DNS captive portal. 

if dsvr then dsvr:close() end 
dns_ip=wifi.ap.getip()
local i1,i2,i3,i4=dns_ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- Grab each byte of the IP

--Convenience vars to hold 0x00 and 0x01, since we'll be using them a bunch
x00=string.char(0)
x01=string.char(1)

-- dns_str1=string.char(128)..x00..x00..x01..x00..x01..x00..x00..x00..x00
-- dns_str2=x00..x01..x00..x01..string.char(192)..string.char(12)..x00..x01..x00..x01..x00..x00..string.char(3)..x00..x00..string.char(4)

dns_str1="\x80\x00\x00\x01\x00\x01\x00\x00\x00\x00"
dns_str2= "\x00\x01\x00\x01\xC0\x0C\x00\x01\x00\x01\x00\x00\x03\x00\x00\x04"

--The IP of this node expressed as a big-endian bytestring
dns_strIP=string.char(i1)..string.char(i2)..string.char(i3)..string.char(i4)  -- Convert to a series of bytes, big endian format. 

dsvr = net.createUDPSocket() -- Create the DNS server 
dsvr:listen(53) -- Listen on DNS port. 
dsvr:on("receive",function(dsvr,dns_pl,port,ip) -- on receive. 
  decodedns(dns_pl) -- decode the request. Optional, just provides info, and makes garbage. 
  dsvr:send(port,ip,dns_tr..dns_str1..dns_q..dns_str2..dns_strIP) -- Send the query info back to the client. 
  collectgarbage("collect") -- Collect the crap we generated. 
end)

function decodedns(dns_pl)
  local a=string.len(dns_pl)
  dns_tr = string.sub(dns_pl, 1, 2)
  local bte=""
  dns_q=""
 
  local i=13
  local bte2=""
  
  while bte2 ~= "0" do
    bte = string.byte(dns_pl,i)
    bte2 = string.format("%x", bte )
    dns_q = dns_q .. string.char(bte)
    i=i+1
  end
  print("DNS QUERY",dns_q) 
end

print("[OK] ----DNS ")