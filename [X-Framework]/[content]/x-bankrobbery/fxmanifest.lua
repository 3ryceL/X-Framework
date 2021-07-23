fx_version 'cerulean'
game 'gta5'

description 'X-BankRobbery'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts { 
	'@x-core/import.lua',
	'config.lua'
}

client_scripts {
    'client/fleeca.lua',
    'client/pacific.lua',
    'client/powerstation.lua',
    'client/doors.lua',
    'client/paleto.lua',
}

server_script 'server/main.lua'

files {
    'html/*',
}
