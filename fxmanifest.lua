fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Mycroft'
description 'Harry Potter Wand in FiveM!'

files {
    "stream/*.*"
}
data_file "DLC_ITYP_REQUEST" "stream/*.ytyp"
this_is_a_map 'yes'
shared_script 'config.lua'
client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}
