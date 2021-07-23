fx_version 'cerulean'
game 'gta5'

description 'X-Anticheat'
version '1.0.0'

shared_scripts { 
	'@x-core/import.lua',
	'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'