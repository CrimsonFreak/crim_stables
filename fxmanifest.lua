fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.' 

author 'CrimsonFreak'
ui_cursor 'yes'

files {
  'UI/dist/assets/*.js',
  'UI/dist/assets/*.css',
  'UI/dist/index.html',
}

ui_page 'UI/dist/index.html'

server_script {
  "Server/main.lua"
}
client_script {
  'Client/*.lua'
}

shared_script {
  "events.lua",
  "data.lua",
  "languages.lua",
  "deathReasons.lua",
  "config.lua",
}