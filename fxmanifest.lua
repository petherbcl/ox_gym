fx_version 'cerulean'
game 'gta5'
lua54 'yes'

games {
	"gta5",
}

name 'ox_gym'
description 'Gym Script'
author 'petherbcl'
version '0.0.1'

shared_scripts {
	"@ox_lib/init.lua",
	'shared/*.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

files {
	"locales/*.json",
}

dependencies {
	"ox_lib",
	"ox_target"
}