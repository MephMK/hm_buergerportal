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
  'shared/texte.lua',
  'shared/field_types.lua',
  'shared/validation.lua',
  'shared/location_schema.lua',
  'shared/permission_actions.lua'
}

client_scripts {
  'client/init.lua',
  'client/esx.lua',
  'client/benachrichtigung.lua',
  'client/ui_bruecke.lua',
  'client/admin_ui_bridge.lua',
  'client/target_adapter.lua',
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
  'server/dienste/permission_service.lua',
  'server/dienste/anti_spam_service.lua',
  'server/dienste/oeffentliche_id_service.lua',
  'server/dienste/status_service.lua',
  'server/dienste/spieler_service.lua',
  'server/dienste/audit_service.lua',

  'server/dienste/kategorie_service.lua',
  'server/dienste/formular_service.lua',
  'server/dienste/feld_validierung_service.lua',
  'server/dienste/antrag_service.lua',

  'server/dienste/justiz_zugriff_service.lua',
  'server/dienste/sperr_service.lua',
  'server/dienste/workflow_service.lua',
  'server/dienste/justiz_antrag_service.lua',
  'server/dienste/justiz_suche_service.lua',

  'server/dienste/rueckfrage_service.lua',
  'server/dienste/nachreichung_service.lua',
  'server/dienste/attachment_service.lua',

  'server/dienste/webhook_service.lua',
  'server/dienste/benachrichtigung_service.lua',
  'server/dienste/payment_service.lua',
  'server/dienste/formular_editor_service.lua',
  'server/dienste/location_service.lua',

  'server/dienste/admin_config_service.lua',
  'server/dienste/admin_audit_service.lua',
  'server/dienste/admin_validierung_service.lua',

  'server/middleware.lua',

  'server/api.lua',
  'server/api_justiz.lua',
  'server/api_workflow.lua',
  'server/api_form_editor.lua',
  'server/api_locations.lua',
  'server/api_attachments.lua',
  'server/api_admin.lua',
  'server/api_admin_crud.lua',
  'server/api_audit.lua',
  'server/api_export.lua'
}

dependencies {
  'oxmysql',
  'es_extended'
}