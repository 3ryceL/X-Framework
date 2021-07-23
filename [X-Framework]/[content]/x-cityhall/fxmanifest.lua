fx_version 'cerulean'
game 'gta5'

description 'X-CityHall'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts { 
	'@x-core/import.lua',
	'config.lua'
}

server_script 'server/main.lua'
client_script 'client/main.lua'

files {
    'html/*.js',
    'html/*.html',
    'html/*.css',
    'html/img/*.png',
    'html/img/*.jpg'
}