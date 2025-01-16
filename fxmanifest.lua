fx_version "cerulean"
game "gta5"
lua54 "yes"

author "kr3mu"
description "script for car selling"
version "1.0"

client_scripts {
    "client.lua",
    "config.lua"
}
server_script "server.lua"


shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
}
