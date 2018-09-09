-- File map for web server. 
--  Format is <ip>/url

TYPE_FILE = 1  -- Looks for a file on SPIFS. 
TYPE_STATIC = 2 -- returns absolute string .

LUT = {
	["/"] = {TYPE_FILE,"index.html"},
	[" /"] = {TYPE_FILE,"index.html"},
	["/gen_204"] = {TYPE_FILE,"204.xx"},
	["/generate_204"] = {TYPE_FILE,"204.xx"},
	["/fursuit.jpg"] = {TYPE_FILE,"fursuit.jpg"},
	["/style.css"] = {TYPE_FILE,"style.css"}
}

print("[OK] ----FSMAP")

