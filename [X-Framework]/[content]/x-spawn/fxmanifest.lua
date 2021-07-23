fx_version 'cerulean'
game 'gta5'

description 'X-Spawn'
version '1.0.0'

shared_scripts {
	'config.lua',
	'@x-core/import.lua',
	'@x-houses/config.lua',
	'@x-apartments/config.lua'
}

client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/style.css',
	'html/script.js',
	'html/reset.css'
}

dependencies {
	'x-core',
	'x-houses',
	'x-interior',
	'x-apartments'
}