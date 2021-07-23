fx_version 'cerulean'
game 'gta5'

description 'X-Apartments'
version '1.0.0'

shared_scripts { 
	'@x-core/import.lua',
	'config.lua'
}

server_script 'server/main.lua'

client_scripts {
	'client/main.lua',
	'client/gui.lua'
}

dependencies {
	'x-core',
	'x-interior',
	'x-clothing',
	'x-weathersync'
}