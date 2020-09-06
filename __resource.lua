resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
    '@es_extended/locale.lua',
	'config.lua',
	'client/client.lua'
}

server_scripts {
	'server/server.lua'
}

ui_page('html/index.html') --THIS IS IMPORTENT

--[[The following is for the files which are need for you UI (like, pictures, the HTML file, css and so on) ]]--
files({
    'html/index.html',
	'html/index_files/script.js',
	'html/index_files/style.css',
	'html/sounds/FirstBlood.mp3',
	'html/sounds/DoubleKill.mp3',
	'html/sounds/TripleKill.mp3',
	'html/sounds/QuadraKill.mp3',
	'html/sounds/PentaKill.mp3',
	'html/sounds/EnemyDoubleKill.mp3',
	'html/sounds/EnemyTripleKill.mp3',
	'html/sounds/EnemyQuadraKill.mp3',
	'html/sounds/EnemyPentaKill.mp3'
})


dependencies {
	'es_extended'
}