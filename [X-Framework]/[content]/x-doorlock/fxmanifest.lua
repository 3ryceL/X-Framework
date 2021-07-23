fx_version 'cerulean'
game 'gta5'

description 'X-Doorlock'
version '1.0.0'

shared_scripts {
	'config.lua',
	'@x-core/import.lua'
}


server_script 'server/main.lua'
client_script 'client/main.lua'
