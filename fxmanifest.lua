

fx_version "bodacious"
game "gta5"



client_scripts {
	"@vrp/lib/vehicles.lua",
	"@vrp/lib/utils.lua",
	"client-side/*",
    "config.lua"
}

server_scripts {
	"@vrp/lib/utils.lua",
	"server-side/*",
	"@vrp/lib/itemlist.lua",
}

ui_page "nui/index.html"

files {
	"nui/*",
	"nui/**/*",
	"nui/**/**/*",
}