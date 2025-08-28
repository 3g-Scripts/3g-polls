fx_version 'cerulean'
lua54 'yes'
game 'gta5'

description 'Basic Poll System'
author '3gdev.tebex.io'
version '1.0.0'

ui_page 'web/build/index.html'

shared_scripts {
  '@ox_lib/init.lua',
  'shared/config.lua'
}

client_scripts {
  'client/client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/classes/vote.lua',
  'server/classes/manager.lua',
  'server/server.lua'
}

files {
  'web/build/index.html',
  'web/build/**/*'
}
