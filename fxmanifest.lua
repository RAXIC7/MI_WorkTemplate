-- FX Information
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

-- Resource Information
name 'mi_worktemplate'
author 'MI_Agimir'
version '1.0.0'
repository 'https://github.com/MIAgimir/MI_WorkTemplate'
description 'Need work? Make a job'

-- Manifest
shared_scripts {
	'config.lua',
}

client_scripts {
    '@ox_core/imports/client.lua',
    'c_main/main.lua',
    'c_util/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@ox_core/imports/server.lua',
    's_main/main.lua',
    's_util/main.lua',
}