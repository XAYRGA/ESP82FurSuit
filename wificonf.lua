wifi.setmode(wifi.SOFTAP)
 cfg={}
 cfg.ssid="Fursuit"
 cfg.auth = wifi.OPEN
 wifi.ap.config(cfg)
 
dhcp_config ={}
dhcp_config.start = "192.168.1.100"
wifi.ap.dhcp.config(dhcp_config)

print("[OK] ----WLAN AP ")