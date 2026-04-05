HM_BP = HM_BP or {}
HM_BP.Server = HM_BP.Server or {}
HM_BP.Server.Dienste = HM_BP.Server.Dienste or {}

local SperrService = {}

local function addSekundenSql(sekunden)
  local now = os.time(os.date("!*t"))
  local t = now + tonumber(sekunden or 0)
  return os.date("!%Y-%m-%d %H:%M:%S", t)
end

function SperrService.AblaufeneSperrenAufraeumen()
  HM_BP.Server.Datenbank.Ausfuehren("DELETE FROM hm_bp_submission_locks WHERE expires_at <= UTC_TIMESTAMP()", {})
end

function SperrService.SperreHolen(antragId)
  return HM_BP.Server.Datenbank.Einzel([[
    SELECT submission_id, locked_by_identifier, locked_by_name, locked_at, expires_at
    FROM hm_bp_submission_locks
    WHERE submission_id = ?
  ]], { antragId })
end

function SperrService.Sperren(spieler, antragId)
  if not (Config.Workflows and Config.Workflows.Sperren and Config.Workflows.Sperren.Aktiviert) then
    return true, nil
  end

  SperrService.AblaufeneSperrenAufraeumen()

  local timeout = tonumber(Config.Workflows.Sperren.TimeoutSekunden or 300) or 300
  local expiresAt = addSekundenSql(timeout)

  local bestehend = SperrService.SperreHolen(antragId)
  if bestehend then
    if bestehend.locked_by_identifier == spieler.identifier then
      -- eigenes Lock verlängern + Name aktualisieren
      HM_BP.Server.Datenbank.Ausfuehren([[
        UPDATE hm_bp_submission_locks
        SET expires_at = ?, locked_by_name = ?
        WHERE submission_id = ?
      ]], { expiresAt, spieler.name, antragId })
      return true, nil
    end

    return false, {
      code = HM_BP.Gemeinsam.Fehlercodes.KONFLIKT,
      nachricht = ("Dieser Antrag wird gerade von %s bearbeitet."):format(bestehend.locked_by_name or "einem Bearbeiter"),
      sperre = {
        von = bestehend.locked_by_name or "Unbekannt",
        identifier = bestehend.locked_by_identifier,
        expires_at = bestehend.expires_at
      }
    }
  end

  HM_BP.Server.Datenbank.Ausfuehren([[
    INSERT INTO hm_bp_submission_locks (submission_id, locked_by_identifier, locked_by_name, expires_at)
    VALUES (?, ?, ?, ?)
  ]], { antragId, spieler.identifier, spieler.name, expiresAt })

  return true, nil
end

function SperrService.Entsperren(spieler, antragId)
  if not (Config.Workflows and Config.Workflows.Sperren and Config.Workflows.Sperren.Aktiviert) then
    return true, nil
  end

  local bestehend = SperrService.SperreHolen(antragId)
  if not bestehend then return true, nil end

  if bestehend.locked_by_identifier ~= spieler.identifier and not HM_BP.Server.Dienste.AuthService.IstAdmin(spieler) then
    return false, { code = HM_BP.Gemeinsam.Fehlercodes.KEINE_BERECHTIGUNG, nachricht = "Du darfst diese Sperre nicht entfernen." }
  end

  HM_BP.Server.Datenbank.Ausfuehren("DELETE FROM hm_bp_submission_locks WHERE submission_id = ?", { antragId })
  return true, nil
end

-- NEU: Alle Sperren eines Bearbeiters lösen (z.B. beim UI schließen)
function SperrService.AlleSperrenDesBearbeitersLoesen(spieler)
  if not (Config.Workflows and Config.Workflows.Sperren and Config.Workflows.Sperren.Aktiviert) then
    return 0
  end

  SperrService.AblaufeneSperrenAufraeumen()

  local affected = HM_BP.Server.Datenbank.Ausfuehren([[
    DELETE FROM hm_bp_submission_locks
    WHERE locked_by_identifier = ?
  ]], { spieler.identifier })

  return tonumber(affected or 0) or 0
end

HM_BP.Server.Dienste.SperrService = SperrService