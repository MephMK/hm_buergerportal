HM_BP = HM_BP or {}
HM_BP.Shared = HM_BP.Shared or {}
HM_BP.Gemeinsam = HM_BP.Gemeinsam or {} -- du nutzt beides (Gemeinsam/Shared) im Code; wir halten beides kompatibel.

-- Hinweis:
-- In deinem Code existieren Referenzen auf:
--  - HM_BP.Shared.Errors / HM_BP.Shared.Texts
--  - HM_BP.Gemeinsam.Fehlercodes / HM_BP.Gemeinsam.Hilfsfunktionen
-- Das bleibt so, damit du später ohne große Refactors erweitern kannst.