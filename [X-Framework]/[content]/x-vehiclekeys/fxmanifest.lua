fx_version 'cerulean'
game 'gta5'

description 'X-VehicleKeys'
version '1.0.0'

shared_script '@x-core/import.lua'
server_script 'server/main.lua'

client_script {
    'client/main.lua',
    'config.lua'
}

dependencies {
    'x-core',
    'x-skillbar'
}