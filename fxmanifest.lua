fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'
use_fxv2_oal 'yes'
ui_page 'html/index.html'

shared_scripts {
	"config.lua"
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'framework/sv_wrapper.lua',
	"server.lua"
}
client_scripts {
	"client.lua",
}

files {
	'html/index.html',
	'html/script.js',
	'html/style.css',
	'html/audio/*.ogg'
}