fx_version 'cerulean'
game 'gta5'

description 'X-Pawnshop'
version '1.0.0'

shared_scripts { 
	'@x-core/import.lua',
	'config.lua'
}

server_script 'server/main.lua'

client_scripts {
	'client/main.lua',
	'client/melt.lua'
}