fx_version 'adamant'

game 'gta5'

description 'XP Ranking System'

author 'Karl Saunders'

version '1.2.2'

server_scripts {
    'config.lua',
    'utils.lua',
    'server/main.lua'
}

client_scripts {
    'config.lua',
    'utils.lua',
    'client/main.lua',
}


ui_page 'ui/ui.html'

files {
    'ui/ui.html',
    'ui/fonts/ChaletComprimeCologneSixty.ttf',
    'ui/css/app.css',
    'ui/js/class.xpm.js',
    'ui/js/class.paginator.js',
    'ui/js/class.leaderboard.js',
    'ui/js/app.js'
}

export 'qb_xpxpSetInitial'
export 'qb_xpxpAdd'
export 'qb_xpxpRemove'
export 'qb_xpxpSetRank'

export 'qb_xpxpGetXP'
export 'qb_xpxpGetRank'
export 'qb_xpxpGetXPToNextRank'
export 'qb_xpxpGetXPToRank'
export 'qb_xpxpGetMaxXP'
export 'qb_xpxpGetMaxRank'

export 'qb_xpxpShowUI'
export 'qb_xpxpHideUI'
export 'qb_xpxpTimeoutUI'
export 'qb_xpxpSortLeaderboard'