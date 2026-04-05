fx_version 'cerulean'
game 'gta5'

name 'hm_buergerportal'
author 'HM Training - Felix Hoffmann'
description 'Modulares Bürgerportal/Antragssystem für Justizzentrum (ESX, oxmysql, NUI) – deutsch'
version '0.5.0'

lua54 'yes'

ui_page 'ui/index.html'

files {
  'ui/index.html',
  'ui/style.css',
  'ui/app.js',
  'ui/assets/logo_justiz_placeholder.png'
}

shared_scripts {
  'config.lua',
  'shared/init.lua',
  'shared/konstanten.lua',
  'shared/hilfsfunktionen.lua',
  'shared/fehlercodes.lua',
  'shared/texte.lua'
}

client_scripts {
  'client/init.lua',
  'client/esx.lua',
  'client/benachrichtigung.lua',
  'client/ui_bruecke.lua',
  'client/standorte.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',

  'server/init.lua',
  'server/startup.lua',

  'server/repository/datenbank.lua',
  'server/repository/migrationen.lua',

  'server/dienste/auth_service.lua',
  'server/dienste/rechte_service.lua',
  'server/dienste/anti_spam_service.lua',
  'server/dienste/oeffentliche_id_service.lua',
  'server/dienste/status_service.lua',
  'server/dienste/spieler_service.lua',

  'server/dienste/kategorie_service.lua',
  'server/dienste/formular_service.lua',
  'server/dienste/feld_validierung_service.lua',
  'server/dienste/antrag_service.lua',

  'server/dienste/justiz_zugriff_service.lua',
  'server/dienste/sperr_service.lua',
  'server/dienste/justiz_antrag_service.lua',
  'server/dienste/justiz_suche_service.lua',

  'server/dienste/rueckfrage_service.lua',

  'server/dienste/webhook_service.lua',
  'server/dienste/formular_editor_service.lua',

  'server/middleware.lua',

  'server/api.lua',
  'server/api_justiz.lua',
  'server/api_form_editor.lua'
}

dependencies {
  'oxmysql',
  'es_extended'
}