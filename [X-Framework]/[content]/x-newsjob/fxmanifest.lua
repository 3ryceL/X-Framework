fx_version 'cerulean'
game 'gta5'

description 'X-NewsJob'
version '1.0.0'

shared_scripts { 
	'@x-core/import.lua',
	'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/camera.lua',
    'client/gui.lua'
}

server_script 'server/main.lua'