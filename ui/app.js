const app = document.getElementById("app");
const btnClose = document.getElementById("btnClose");
const btnReload = document.getElementById("btnReload");

const spielerName = document.getElementById("spielerName");
const rolle = document.getElementById("rolle");
const jobGrad = document.getElementById("jobGrad");
const standortName = document.getElementById("standortName");

const fehlerBox = document.getElementById("fehlerBox");

const tabBuerger = document.getElementById("tabBuerger");
const tabJustiz = document.getElementById("tabJustiz");

const bereichBuergerSidebar = document.getElementById("bereichBuergerSidebar");
const bereichJustizSidebar = document.getElementById("bereichJustizSidebar");
const bereichBuergerContent = document.getElementById("bereichBuergerContent");
const bereichJustizContent = document.getElementById("bereichJustizContent");

const kategorienListe = document.getElementById("kategorienListe");
const formulareListe = document.getElementById("formulareListe");
const meineAntraegeListe = document.getElementById("meineAntraegeListe");
const formularTitel = document.getElementById("formularTitel");
const formularBeschreibung = document.getElementById("formularBeschreibung");
const felderContainer = document.getElementById("felderContainer");

const btnEinreichen = document.getElementById("btnEinreichen");
const einreichenStatus = document.getElementById("einreichenStatus");

const btnPublicIdTest = document.getElementById("btnPublicIdTest");
const publicIdAusgabe = document.getElementById("publicIdAusgabe");

const justizKategorienListe = document.getElementById("justizKategorienListe");
const tabEingang = document.getElementById("tabEingang");
const tabZugewiesen = document.getElementById("tabZugewiesen");
const tabAlleKategorie = document.getElementById("tabAlleKategorie");
const tabArchiv = document.getElementById("tabArchiv");
const justizAntraegeListe = document.getElementById("justizAntraegeListe");

const justizDetailsHeader = document.getElementById("justizDetailsHeader");
const justizSperreHinweis = document.getElementById("justizSperreHinweis");

const btnJustizUebernehmen = document.getElementById("btnJustizUebernehmen");

const justizBearbeiterSelect = document.getElementById("justizBearbeiterSelect");
const justizBearbeiterMeta = document.getElementById("justizBearbeiterMeta");
const btnJustizBearbeiterRefresh = document.getElementById("btnJustizBearbeiterRefresh");
const btnJustizZuweisen = document.getElementById("btnJustizZuweisen");

const justizPrioritaetSelect = document.getElementById("justizPrioritaetSelect");
const btnJustizPrioritaetSetzen = document.getElementById("btnJustizPrioritaetSetzen");

const justizArchivGrund = document.getElementById("justizArchivGrund");
const btnJustizArchivieren = document.getElementById("btnJustizArchivieren");

const justizStatusSelect = document.getElementById("justizStatusSelect");
const justizStatusKommentar = document.getElementById("justizStatusKommentar");
const btnJustizStatusSetzen = document.getElementById("btnJustizStatusSetzen");
const justizStatusResult = document.getElementById("justizStatusResult");

const justizInterneNotizText = document.getElementById("justizInterneNotizText");
const btnJustizInterneNotiz = document.getElementById("btnJustizInterneNotiz");

const justizOeffentlicheAntwortText = document.getElementById("justizOeffentlicheAntwortText");
const btnJustizOeffentlicheAntwort = document.getElementById("btnJustizOeffentlicheAntwort");

const justizRueckfrageText = document.getElementById("justizRueckfrageText");
const btnJustizRueckfrageStellen = document.getElementById("btnJustizRueckfrageStellen");
const justizRueckfrageMeta = document.getElementById("justizRueckfrageMeta");

const justizVerlauf = document.getElementById("justizVerlauf");

// Suche/Filter UI
const justizSearchQuery = document.getElementById("justizSearchQuery");
const justizFilterStatus = document.getElementById("justizFilterStatus");
const justizFilterPrio = document.getElementById("justizFilterPrio");
const justizFilterDateFrom = document.getElementById("justizFilterDateFrom");
const justizFilterDateTo = document.getElementById("justizFilterDateTo");
const justizSortBy = document.getElementById("justizSortBy");
const justizSortDir = document.getElementById("justizSortDir");
const btnJustizSuchen = document.getElementById("btnJustizSuchen");
const btnJustizFilterReset = document.getElementById("btnJustizFilterReset");
const justizSearchMeta = document.getElementById("justizSearchMeta");

// Bürger Details UI
const buergerDetailsHeader = document.getElementById("buergerDetailsHeader");
const buergerVerlauf = document.getElementById("buergerVerlauf");
const buergerAntwortText = document.getElementById("buergerAntwortText");
const btnBuergerAntwortSenden = document.getElementById("btnBuergerAntwortSenden");
const buergerAntwortMeta = document.getElementById("buergerAntwortMeta");

// Nachreichen UI
const buergerNachreichenSection = document.getElementById("buergerNachreichenSection");
const buergerNachreichenFelder = document.getElementById("buergerNachreichenFelder");
const btnBuergerNachreichen = document.getElementById("btnBuergerNachreichen");
const buergerNachreichenMeta = document.getElementById("buergerNachreichenMeta");

// ===== NEU: Formular-Editor UI Elements =====
const formEditorMeta = document.getElementById("formEditorMeta");
const formEditorBox = document.getElementById("formEditorBox");
const formEditorKategorieSelect = document.getElementById("formEditorKategorieSelect");
const formEditorFormListe = document.getElementById("formEditorFormListe");

const formEditorNewId = document.getElementById("formEditorNewId");
const formEditorNewTitel = document.getElementById("formEditorNewTitel");
const formEditorNewBeschreibung = document.getElementById("formEditorNewBeschreibung");
const btnFormEditorCreate = document.getElementById("btnFormEditorCreate");
const formEditorCreateMeta = document.getElementById("formEditorCreateMeta");

const formEditorFormHeader = document.getElementById("formEditorFormHeader");
const formEditorFeldListe = document.getElementById("formEditorFeldListe");

const formEditorFieldKey = document.getElementById("formEditorFieldKey");
const formEditorFieldTyp = document.getElementById("formEditorFieldTyp");
const formEditorFieldLabel = document.getElementById("formEditorFieldLabel");
const formEditorFieldPlaceholder = document.getElementById("formEditorFieldPlaceholder");
const formEditorFieldPflicht = document.getElementById("formEditorFieldPflicht");
const formEditorFieldOrder = document.getElementById("formEditorFieldOrder");
const formEditorFieldMin = document.getElementById("formEditorFieldMin");
const formEditorFieldMax = document.getElementById("formEditorFieldMax");
const formEditorFieldRegex = document.getElementById("formEditorFieldRegex");
const formEditorFieldOptionen = document.getElementById("formEditorFieldOptionen");
const btnFormEditorFieldAdd = document.getElementById("btnFormEditorFieldAdd");
const formEditorFieldAddMeta = document.getElementById("formEditorFieldAddMeta");

const btnFormEditorSave = document.getElementById("btnFormEditorSave");
const btnFormEditorPublish = document.getElementById("btnFormEditorPublish");
const btnFormEditorArchive = document.getElementById("btnFormEditorArchive");
const formEditorPreview = document.getElementById("formEditorPreview");
const formEditorActionMeta = document.getElementById("formEditorActionMeta");

// ==========================
// State
// ==========================
let ausgewaehlteKategorieId = null;
let ausgewaehltesFormularId = null;
let aktuellesSchema = null;

let justizKategorien = [];
let ausgewaehlteJustizKategorieId = null;
let ausgewaehlteQueue = "eingang";
let ausgewaehlterJustizAntragId = null;

let aktuellerSpieler = { rolle: null, identifier: null };
let aktuellesJustizRegelObjekt = null; // { sehen, aktionen }
let aktuellerLock = null;
let gesperrtVonAnderem = false;

let prioritaetenListe = [];
let bearbeiterListe = [];
let statusListeAktuell = [];

let justizSuchModusAktiv = false;

let ausgewaehlterBuergerAntragId = null;
let buergerRueckfrageOffen = false;
let buergerNachreichungErlaubt = false;
let buergerAktuellerPayload = null; // { fields_snapshot, answers } für Nachreichen

window.__hm_bp_aktuellerStatus = null;

// Formular-Editor State
let formEditorRechte = {}; // kategorieId -> {create,edit,publish,archive}
let formEditorKategorieId = null;
let formEditorFormId = null;
let formEditorSchemaDraft = null;
let formEditorFormListeState = [];

// ==========================
// Helpers
// ==========================
function nuiAufruf(eventName, daten) {
  return fetch(`https://${GetParentResourceName()}/${eventName}`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(daten || {})
  })
    .then(r => r.json())
    .catch(() => ({ ok: false }));
}

function fehlerAnzeigen(text) {
  fehlerBox.style.display = "block";
  fehlerBox.textContent = text || "Unbekannter Fehler.";
}

function fehlerVerstecken() {
  fehlerBox.style.display = "none";
  fehlerBox.textContent = "";
}

function escapeHtml(str) {
  return String(str || "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function listeLeeren(el) { el.innerHTML = ""; }

function itemErstellen({ name, desc, active, onclick }) {
  const div = document.createElement("div");
  div.className = "item" + (active ? " active" : "");
  div.innerHTML = `<div class="name">${escapeHtml(name)}</div>${desc ? `<div class="desc">${escapeHtml(desc)}</div>` : ""}`;
  div.addEventListener("click", onclick);
  return div;
}

function normName(name) {
  const s = String(name || "").trim();
  return s ? s : "Unbekannt";
}

function parseOptionLines(text) {
  const arr = String(text || "").split("\n").map(x => x.trim()).filter(Boolean);
  const out = [];
  for (const line of arr) {
    if (line.includes("|")) {
      const [label, value] = line.split("|").map(x => x.trim());
      if (!value) continue;
      out.push({ label: label || value, value });
    } else {
      out.push(line);
    }
  }
  return out;
}

// ==========================
// Tabs (Bürger/Justiz)
// ==========================
function tabSetzen(bereich) {
  const tabAdmin = document.getElementById("tabAdmin");
  const bereichAdminContent = document.getElementById("bereichAdminContent");

  if (bereich === "buerger") {
    tabBuerger.classList.add("active");
    tabJustiz.classList.remove("active");
    if (tabAdmin) tabAdmin.classList.remove("active");
    bereichBuergerSidebar.style.display = "block";
    bereichJustizSidebar.style.display = "none";
    bereichBuergerContent.style.display = "block";
    bereichJustizContent.style.display = "none";
    if (bereichAdminContent) bereichAdminContent.style.display = "none";
  } else if (bereich === "admin") {
    if (tabAdmin) tabAdmin.classList.add("active");
    tabBuerger.classList.remove("active");
    tabJustiz.classList.remove("active");
    bereichBuergerSidebar.style.display = "none";
    bereichJustizSidebar.style.display = "none";
    bereichBuergerContent.style.display = "none";
    bereichJustizContent.style.display = "none";
    if (bereichAdminContent) bereichAdminContent.style.display = "block";
  } else {
    tabJustiz.classList.add("active");
    tabBuerger.classList.remove("active");
    if (tabAdmin) tabAdmin.classList.remove("active");
    bereichJustizSidebar.style.display = "block";
    bereichBuergerSidebar.style.display = "none";
    bereichJustizContent.style.display = "block";
    bereichBuergerContent.style.display = "none";
    if (bereichAdminContent) bereichAdminContent.style.display = "none";
  }
}

// ==========================
// Bürger: dynamische Formulare
// ==========================

// Kanonische Typ-Aliase (Client-Seite, spiegelt shared/field_types.lua)
const FELD_TYP_ALIAS = {
  shorttext: "text_short",
  longtext: "text_long",
  dropdown: "select",
  kennzeichen: "license_plate",
  spieler: "player_reference",
  firma: "company_reference",
  aktenzeichen: "case_number",
  betrag: "amount",
  datum: "date",
  uhrzeit: "time",
  datumzeit: "datetime",
  mehrfachauswahl: "multiselect",
};

// Dekorative Typen (kein Eingabefeld)
const FELD_TYP_DEKORATIV = new Set(["divider", "heading", "info"]);

// Typen mit Optionsliste
const FELD_TYP_MIT_OPTIONEN = new Set(["select", "multiselect", "radio"]);

function normalisiereFeldTyp(typ) {
  if (!typ) return "text_short";
  const t = String(typ).toLowerCase();
  return FELD_TYP_ALIAS[t] || t;
}

function baueOptionenSelect(feld, mehrfach) {
  const sel = document.createElement("select");
  if (mehrfach) {
    sel.multiple = true;
    sel.size = Math.min(Math.max((feld.optionen || []).length, 2), 8);
  } else {
    const opt0 = document.createElement("option");
    opt0.value = "";
    opt0.textContent = "Bitte auswählen...";
    sel.appendChild(opt0);
  }
  const opts = Array.isArray(feld.optionen) ? feld.optionen : [];
  for (const o of opts) {
    const opt = document.createElement("option");
    const val = typeof o === "string" ? o : (o.value ?? o);
    const lbl = typeof o === "string" ? o : (o.label || o.value || o);
    opt.value = String(val);
    opt.textContent = String(lbl);
    sel.appendChild(opt);
  }
  return sel;
}

function feldElementErstellen(feld) {
  const wrapper = document.createElement("div");
  const typ = normalisiereFeldTyp(feld.typ);

  // --- Dekorative Elemente ---
  if (typ === "divider") {
    wrapper.className = "feld feld-divider";
    const hr = document.createElement("hr");
    wrapper.appendChild(hr);
    return wrapper;
  }
  if (typ === "heading") {
    wrapper.className = "feld feld-heading";
    const h = document.createElement("div");
    h.className = "feld-heading-text";
    h.textContent = feld.label || "";
    wrapper.appendChild(h);
    if (feld.beschreibung) {
      const sub = document.createElement("div");
      sub.className = "hint";
      sub.textContent = feld.beschreibung;
      wrapper.appendChild(sub);
    }
    return wrapper;
  }
  if (typ === "info") {
    wrapper.className = "feld feld-info";
    const p = document.createElement("div");
    p.className = "feld-info-text";
    p.textContent = feld.label || feld.beschreibung || "";
    wrapper.appendChild(p);
    return wrapper;
  }

  // --- Eingabefelder ---
  wrapper.className = "feld";
  wrapper.dataset.key = feld.key;

  const label = document.createElement("div");
  label.className = "label";
  label.textContent = (feld.label || feld.key) + (feld.pflicht ? " *" : "");
  wrapper.appendChild(label);

  let input = null;

  if (typ === "text_short") {
    input = document.createElement("input");
    input.type = "text";
    input.placeholder = feld.placeholder || "";
    if (feld.maxLaenge) input.maxLength = feld.maxLaenge;

  } else if (typ === "text_long") {
    input = document.createElement("textarea");
    input.placeholder = feld.placeholder || "";
    if (feld.maxLaenge) input.maxLength = feld.maxLaenge;

  } else if (typ === "number") {
    input = document.createElement("input");
    input.type = "number";
    input.step = "any";
    if (feld.min !== undefined && feld.min !== null) input.min = feld.min;
    if (feld.max !== undefined && feld.max !== null) input.max = feld.max;

  } else if (typ === "amount") {
    input = document.createElement("input");
    input.type = "number";
    input.step = "0.01";
    input.min = feld.min !== undefined && feld.min !== null ? feld.min : "0";
    if (feld.max !== undefined && feld.max !== null) input.max = feld.max;
    input.placeholder = "0.00";

  } else if (typ === "date") {
    input = document.createElement("input");
    input.type = "date";

  } else if (typ === "time") {
    input = document.createElement("input");
    input.type = "time";

  } else if (typ === "datetime") {
    input = document.createElement("input");
    input.type = "datetime-local";

  } else if (typ === "checkbox") {
    input = document.createElement("input");
    input.type = "checkbox";

  } else if (typ === "select" || typ === "radio") {
    input = baueOptionenSelect(feld, false);

  } else if (typ === "multiselect") {
    input = baueOptionenSelect(feld, true);

  } else if (typ === "url") {
    input = document.createElement("input");
    input.type = "url";
    input.placeholder = feld.placeholder || "https://...";
    if (feld.maxLaenge) input.maxLength = feld.maxLaenge;

  } else if (typ === "license_plate") {
    input = document.createElement("input");
    input.type = "text";
    input.placeholder = feld.placeholder || "z.B. AB 1234";
    input.style.textTransform = "uppercase";
    if (feld.maxLaenge) input.maxLength = feld.maxLaenge;

  } else if (typ === "player_reference" || typ === "company_reference") {
    input = document.createElement("input");
    input.type = "text";
    input.placeholder = feld.placeholder || "";
    if (feld.maxLaenge) input.maxLength = feld.maxLaenge;

  } else if (typ === "case_number") {
    input = document.createElement("input");
    input.type = "text";
    input.placeholder = feld.placeholder || "z.B. DOJ-2024-000123";
    if (feld.maxLaenge) input.maxLength = feld.maxLaenge;

  } else {
    // Unbekannter Typ: Fallback Kurztext (backwards-compat)
    input = document.createElement("input");
    input.type = "text";
    input.placeholder = feld.placeholder || "";
  }

  input.dataset.key = feld.key;
  wrapper.appendChild(input);

  const fehlertext = document.createElement("div");
  fehlertext.className = "fehlertext";
  fehlertext.textContent = "Ungültiger Wert.";
  wrapper.appendChild(fehlertext);

  if (feld.beschreibung) {
    const hint = document.createElement("div");
    hint.className = "hint";
    hint.textContent = feld.beschreibung;
    wrapper.appendChild(hint);
  }

  // Standardwert
  if (feld.standardwert !== undefined && feld.standardwert !== null) {
    if (typ === "checkbox") {
      input.checked = !!feld.standardwert;
    } else if (typ === "multiselect" && Array.isArray(feld.standardwert)) {
      const vals = new Set(feld.standardwert.map(String));
      for (const opt of input.options) {
        if (vals.has(opt.value)) opt.selected = true;
      }
    } else if (typ === "datetime") {
      // datetime-local format: YYYY-MM-DDTHH:MM
      input.value = String(feld.standardwert).replace(" ", "T").substring(0, 16);
    } else {
      input.value = String(feld.standardwert);
    }
  }

  return wrapper;
}

function schemaRendern(schema) {
  aktuellesSchema = schema;
  felderContainer.innerHTML = "";

  const formular = schema.formular || {};
  formularTitel.textContent = formular.titel || "Formular";
  formularBeschreibung.textContent = formular.beschreibung || "";

  const felder = Array.isArray(schema.felder) ? schema.felder : [];
  // Nach reihenfolge sortieren falls vorhanden
  const sortiert = [...felder].sort((a, b) => (a.reihenfolge || 999) - (b.reihenfolge || 999));
  for (const feld of sortiert) felderContainer.appendChild(feldElementErstellen(feld));
}

function antwortenEinsammeln() {
  const daten = {};
  if (!aktuellesSchema || !Array.isArray(aktuellesSchema.felder)) return daten;

  for (const feld of aktuellesSchema.felder) {
    const typ = normalisiereFeldTyp(feld.typ);
    // Dekorative Felder überspringen
    if (FELD_TYP_DEKORATIV.has(typ)) continue;

    const el = felderContainer.querySelector(`.feld[data-key="${CSS.escape(feld.key)}"]`);
    if (!el) continue;
    const input = el.querySelector(`[data-key="${CSS.escape(feld.key)}"]`);
    if (!input) continue;

    if (typ === "checkbox") {
      daten[feld.key] = !!input.checked;
    } else if (typ === "number" || typ === "amount") {
      daten[feld.key] = input.value === "" ? null : Number(input.value);
    } else if (typ === "multiselect") {
      const ausgewaehlt = [];
      for (const opt of input.selectedOptions) ausgewaehlt.push(opt.value);
      daten[feld.key] = ausgewaehlt.length > 0 ? ausgewaehlt : null;
    } else if (typ === "datetime") {
      // Konvertiere datetime-local (YYYY-MM-DDTHH:MM) zu ISO-ähnlichem Format
      daten[feld.key] = input.value === "" ? null : input.value;
    } else {
      daten[feld.key] = input.value === "" ? null : input.value;
    }
  }

  return daten;
}

// ==========================
// Client-seitige UI-Helper-Validierung
// Spiegelt die Serverlogik (shared/validation.lua) für sofortiges Feedback.
// SERVER bleibt Source of Truth – diese Funktion ist nur UX-Unterstützung.
// ==========================
function clientFeldValidieren(feld, wert) {
  const typ = normalisiereFeldTyp(feld.typ);
  if (FELD_TYP_DEKORATIV.has(typ)) return null;

  const istLeer = (v) => v === null || v === undefined || v === "" || (Array.isArray(v) && v.length === 0);

  // Pflicht-Check
  if (feld.pflicht && istLeer(wert)) {
    return "Pflichtfeld";
  }

  // Kein weiterer Check wenn leer und nicht Pflicht
  if (istLeer(wert) && typ !== "checkbox") return null;

  if (typ === "text_short" || typ === "text_long" || typ === "player_reference" || typ === "company_reference") {
    const s = String(wert || "").trim();
    const minL = feld.minLaenge ?? feld.min;
    const maxL = feld.maxLaenge ?? feld.max;
    if (minL && s.length < Number(minL)) return `Mindestens ${minL} Zeichen erforderlich`;
    if (maxL && s.length > Number(maxL)) return `Maximal ${maxL} Zeichen erlaubt`;
    if (feld.regex) {
      try {
        if (!new RegExp(feld.regex).test(s)) return "Ungültiges Format";
      } catch (_) { /* ungültiger Regex – ignorieren */ }
    }
  } else if (typ === "number" || typ === "amount") {
    const n = Number(wert);
    if (isNaN(n)) return "Muss eine Zahl sein";
    if (feld.min !== undefined && feld.min !== null && n < Number(feld.min)) return `Mindestens ${feld.min}`;
    if (feld.max !== undefined && feld.max !== null && n > Number(feld.max)) return `Maximal ${feld.max}`;
  } else if (typ === "checkbox") {
    if (feld.pflicht && !wert) return "Muss bestätigt werden";
  } else if (typ === "select" || typ === "radio") {
    if (feld.pflicht && (!wert || wert === "")) return "Bitte auswählen";
  } else if (typ === "multiselect") {
    if (feld.pflicht && Array.isArray(wert) && wert.length === 0) return "Mindestens eine Auswahl erforderlich";
  } else if (typ === "date") {
    if (wert && !/^\d{4}-\d{2}-\d{2}$/.test(String(wert))) return "Ungültiges Datum (JJJJ-MM-TT)";
  } else if (typ === "time") {
    if (wert && !/^\d{2}:\d{2}$/.test(String(wert))) return "Ungültige Uhrzeit (HH:MM)";
  } else if (typ === "datetime") {
    if (wert && !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/.test(String(wert))) return "Ungültiges Datum/Uhrzeit";
  } else if (typ === "url") {
    if (wert && !/^https?:\/\//.test(String(wert))) return "Muss mit http:// oder https:// beginnen";
  } else if (typ === "license_plate") {
    if (wert && !/^[A-Za-z]+[-]?[A-Za-z]* ?\d+$/.test(String(wert).trim())) return "Ungültiges Kennzeichen";
  } else if (typ === "case_number") {
    if (wert && !/^[A-Za-z0-9\-_]+$/.test(String(wert).trim())) return "Ungültiges Aktenzeichen";
  }

  return null;
}

function clientSchemaValidieren(schema, antworten) {
  const fehler = {};
  if (!schema || !Array.isArray(schema.felder)) return fehler;

  for (const feld of schema.felder) {
    if (!feld.key) continue;
    const wert = antworten[feld.key];
    const msg = clientFeldValidieren(feld, wert);
    if (msg) fehler[feld.key] = msg;
  }
  return fehler;
}

function feldFehlerSetzen(feldFehler) {
  const map = feldFehler || {};
  for (const feldDiv of felderContainer.querySelectorAll(".feld")) {
    feldDiv.classList.remove("invalid");
    const key = feldDiv.dataset.key;
    if (map[key]) {
      feldDiv.classList.add("invalid");
      const f = feldDiv.querySelector(".fehlertext");
      if (f) f.textContent = map[key];
    }
  }
}

// ==========================
// Bürger: Listen Render
// ==========================
function kategorienRendern(kategorien) {
  listeLeeren(kategorienListe);
  const arr = Array.isArray(kategorien) ? kategorien : [];
  if (arr.length === 0) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Keine Kategorien verfügbar.";
    kategorienListe.appendChild(m);
    return;
  }

  for (const k of arr) {
    kategorienListe.appendChild(itemErstellen({
      name: k.name,
      desc: k.beschreibung,
      active: ausgewaehlteKategorieId === k.id,
      onclick: () => {
        ausgewaehlteKategorieId = k.id;
        ausgewaehltesFormularId = null;
        aktuellesSchema = null;

        feldFehlerSetzen({});
        einreichenStatus.textContent = "";

        listeLeeren(formulareListe);
        felderContainer.innerHTML = "";

        formularTitel.textContent = "Formulare";
        formularBeschreibung.textContent = "Bitte ein Formular auswählen.";

        nuiAufruf("hm_bp:formulare_laden", { kategorieId: k.id });
        kategorienRendern(arr);
      }
    }));
  }
}

function formulareRendern(formulare) {
  listeLeeren(formulareListe);
  const arr = Array.isArray(formulare) ? formulare : [];
  if (arr.length === 0) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Keine Formulare in dieser Kategorie.";
    formulareListe.appendChild(m);
    return;
  }

  for (const f of arr) {
    const badge = f.quelle === "db" ? " <span class=\"badge badge-ok\">DB</span>" : "";
    const div = itemErstellen({
      name: f.titel,
      desc: f.beschreibung,
      active: ausgewaehltesFormularId === f.id,
      onclick: () => {
        ausgewaehltesFormularId = f.id;
        aktuellesSchema = null;

        feldFehlerSetzen({});
        einreichenStatus.textContent = "";

        nuiAufruf("hm_bp:formular_schema_laden", { formularId: f.id });
        formulareRendern(arr);
      }
    });
    div.querySelector(".name").innerHTML = `${escapeHtml(f.titel)}${badge}`;
    formulareListe.appendChild(div);
  }
}

function antraegeRendern(antraege) {
  listeLeeren(meineAntraegeListe);
  const arr = Array.isArray(antraege) ? antraege : [];
  if (arr.length === 0) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Du hast noch keine Anträge.";
    meineAntraegeListe.appendChild(m);
    return;
  }

  for (const a of arr) {
    const titel = `${a.public_id} (${a.status})`;
    const desc = `Formular: ${a.form_id} | Priorität: ${a.priority}`;
    meineAntraegeListe.appendChild(itemErstellen({
      name: titel,
      desc,
      active: ausgewaehlterBuergerAntragId === a.id,
      onclick: () => {
        ausgewaehlterBuergerAntragId = a.id;
        buergerAntwortMeta.textContent = "";
        buergerNachreichenMeta.textContent = "";
        buergerNachreichenUiSetzen(false, null);
        nuiAufruf("hm_bp:antrag_details_mein_laden", { antragId: a.id });
        antraegeRendern(arr);
      }
    }));
  }
}

// ==========================
// Bürger: Details + Verlauf + Antwort
// ==========================
function buergerVerlaufRendern(timeline) {
  buergerVerlauf.innerHTML = "";
  const arr = Array.isArray(timeline) ? timeline : [];
  if (arr.length === 0) {
    buergerVerlauf.innerHTML = `<div class="muted">Kein Verlauf.</div>`;
    return;
  }

  for (const e of arr) {
    const meta = `${e.created_at} | ${e.entry_type} | ${e.author_name || "-"}`;
    let text = "";
    try {
      const c = typeof e.content === "string" ? JSON.parse(e.content) : e.content;
      text = c && c.text ? c.text : JSON.stringify(c);
    } catch {
      text = String(e.content || "");
    }

    const div = document.createElement("div");
    div.className = "eintrag";
    div.innerHTML = `<div class="meta">${escapeHtml(meta)}</div><div>${escapeHtml(text)}</div>`;
    buergerVerlauf.appendChild(div);
  }
}

function buergerAntwortUiSetzen(erlaubt, metaText) {
  buergerRueckfrageOffen = !!erlaubt;
  btnBuergerAntwortSenden.disabled = !buergerRueckfrageOffen;
  buergerAntwortText.disabled = !buergerRueckfrageOffen;
  buergerAntwortMeta.textContent = metaText || (buergerRueckfrageOffen ? "Rückfrage offen – du kannst antworten." : "Keine Rückfrage offen – Antworten ist deaktiviert.");
}

// ==========================
// Bürger: Nachreichen UI
// ==========================
function buergerNachreichenUiSetzen(erlaubt, payload) {
  buergerNachreichungErlaubt = !!erlaubt;
  buergerAktuellerPayload = payload || null;
  buergerNachreichenSection.style.display = erlaubt ? "block" : "none";
  buergerNachreichenMeta.textContent = "";

  if (!erlaubt || !payload) {
    buergerNachreichenFelder.innerHTML = "";
    return;
  }

  // Felder aus fields_snapshot rendern (bereits ausgefüllte = disabled)
  let felderSnapshot = [];
  try {
    felderSnapshot = Array.isArray(payload.fields_snapshot)
      ? payload.fields_snapshot
      : JSON.parse(payload.fields_snapshot || "[]");
  } catch { felderSnapshot = []; }

  let bestehendeAntworten = {};
  try {
    bestehendeAntworten = (typeof payload.answers === "object" && payload.answers !== null)
      ? payload.answers
      : JSON.parse(payload.answers || "{}");
  } catch { bestehendeAntworten = {}; }

  buergerNachreichenFelder.innerHTML = "";

  if (felderSnapshot.length === 0) {
    buergerNachreichenFelder.innerHTML = `<div class="muted">Keine Felder im Snapshot vorhanden.</div>`;
    return;
  }

  for (const feld of felderSnapshot) {
    if (!feld.key) continue;
    // Dekorative Felder überspringen
    const feldTyp = normalisiereFeldTyp(feld.typ);
    if (FELD_TYP_DEKORATIV.has(feldTyp)) continue;
    // Nur Felder anzeigen, die sichtbar für Bürger sind (falls Metadatum gesetzt)
    if (feld.sichtbarFuerBuerger === false) continue;

    const vorhanden = bestehendeAntworten[feld.key];
    const istAusgefuellt = vorhanden !== undefined && vorhanden !== null &&
      (Array.isArray(vorhanden) ? vorhanden.length > 0 : String(vorhanden).trim() !== "");
    const wrapper = feldElementErstellen({ ...feld, pflicht: false });

    // Bereits ausgefüllte Felder deaktivieren
    const inputs = wrapper.querySelectorAll("input, textarea, select");
    if (istAusgefuellt) {
      inputs.forEach(el => {
        el.disabled = true;
        if (el.type === "checkbox") {
          el.checked = !!vorhanden;
        } else if (el.multiple && Array.isArray(vorhanden)) {
          const vals = new Set(vorhanden.map(String));
          for (const opt of el.options) opt.selected = vals.has(opt.value);
        } else {
          el.value = String(vorhanden);
        }
      });
      const hinweis = document.createElement("div");
      hinweis.className = "muted";
      hinweis.textContent = "Bereits ausgefüllt – kann nicht geändert werden.";
      wrapper.appendChild(hinweis);
    } else {
      // Leere Felder sind editierbar
      inputs.forEach(el => { el.disabled = false; });
    }

    buergerNachreichenFelder.appendChild(wrapper);
  }

  const hatLeereFelder = felderSnapshot.some(f => {
    if (!f.key || f.sichtbarFuerBuerger === false) return false;
    const feldTyp = normalisiereFeldTyp(f.typ);
    if (FELD_TYP_DEKORATIV.has(feldTyp)) return false;
    const v = bestehendeAntworten[f.key];
    if (v === undefined || v === null) return true;
    if (Array.isArray(v)) return v.length === 0;
    return String(v).trim() === "";
  });

  if (!hatLeereFelder) {
    const hinweis = document.createElement("div");
    hinweis.className = "muted";
    hinweis.textContent = "Alle Felder sind bereits ausgefüllt. Keine Nachreichung erforderlich.";
    buergerNachreichenFelder.appendChild(hinweis);
    btnBuergerNachreichen.disabled = true;
  } else {
    btnBuergerNachreichen.disabled = false;
  }
}
function justizKategorienRendern(liste) {
  justizKategorien = Array.isArray(liste) ? liste : [];
  listeLeeren(justizKategorienListe);

  if (justizKategorien.length === 0) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Keine Justiz-Kategorien verfügbar.";
    justizKategorienListe.appendChild(m);
    return;
  }

  for (const k of justizKategorien) {
    justizKategorienListe.appendChild(itemErstellen({
      name: k.name,
      desc: k.beschreibung,
      active: ausgewaehlteJustizKategorieId === k.id,
      onclick: () => {
        ausgewaehlteJustizKategorieId = k.id;

        justizSuchModusAktiv = false;
        justizSearchMeta.textContent = "";

        ausgewaehlterJustizAntragId = null;
        aktuellesJustizRegelObjekt = null;
        aktuellerLock = null;
        gesperrtVonAnderem = false;

        justizDetailsHeader.textContent = "Bitte links einen Antrag auswählen.";
        justizSperreHinweis.style.display = "none";
        listeLeeren(justizAntraegeListe);
        justizVerlauf.innerHTML = "";
        justizStatusResult.textContent = "";
        justizRueckfrageMeta.textContent = "";
        justizRueckfrageText.value = "";

        // Formular-Editor: Kategorie vorauswählen, wenn Rechte vorhanden
        formEditorKategorieId = null;
        formEditorFormId = null;
        formEditorSchemaDraft = null;
        renderFormEditorHeader();
        renderFormEditorFields();
        renderFormEditorPreview();
        updateFormEditorButtons();

        justizQueueLaden();
        justizKategorienRendern(justizKategorien);
        setBearbeitungNachRegeln();

        // Editor-Rechte + UI aktualisieren
        formEditorInitKategorieSelect();
      }
    }));
  }

  // beim ersten Mal: KategorieSelect befüllen
  formEditorInitKategorieSelect();
}

function justizAntraegeRendern(liste) {
  listeLeeren(justizAntraegeListe);
  const arr = Array.isArray(liste) ? liste : [];
  if (arr.length === 0) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Keine Anträge gefunden.";
    justizAntraegeListe.appendChild(m);
    return;
  }

  for (const a of arr) {
    const titel = `${a.public_id} (${a.status})`;
    const buergerName = normName(a.citizen_name);
    const desc = `Bürger: ${buergerName} | Priorität: ${a.priority} | Bearbeiter: ${a.assigned_to_name || "-"}`;
    justizAntraegeListe.appendChild(itemErstellen({
      name: titel,
      desc,
      active: ausgewaehlterJustizAntragId === a.id,
      onclick: () => {
        ausgewaehlterJustizAntragId = a.id;
        justizStatusResult.textContent = "";
        justizRueckfrageMeta.textContent = "";
        nuiAufruf("hm_bp:justiz_details_laden", { antragId: a.id });
        justizAntraegeRendern(arr);
      }
    }));
  }
}

function setQueueTabsEnabled(sehen) {
  const s = sehen || {};
  tabEingang.disabled = !(s.eingang === true);
  tabZugewiesen.disabled = !(s.zugewiesen === true);
  tabAlleKategorie.disabled = !(s.alleKategorie === true);
  tabArchiv.disabled = !(s.archiv === true);

  if (ausgewaehlteQueue === "eingang" && tabEingang.disabled) {
    if (!tabZugewiesen.disabled) queueTabSetzen("zugewiesen");
    else if (!tabAlleKategorie.disabled) queueTabSetzen("alle");
    else if (!tabArchiv.disabled) queueTabSetzen("archiv");
  }
  if (ausgewaehlteQueue === "zugewiesen" && tabZugewiesen.disabled) {
    if (!tabEingang.disabled) queueTabSetzen("eingang");
    else if (!tabAlleKategorie.disabled) queueTabSetzen("alle");
    else if (!tabArchiv.disabled) queueTabSetzen("archiv");
  }
  if (ausgewaehlteQueue === "alle" && tabAlleKategorie.disabled) {
    if (!tabEingang.disabled) queueTabSetzen("eingang");
    else if (!tabZugewiesen.disabled) queueTabSetzen("zugewiesen");
    else if (!tabArchiv.disabled) queueTabSetzen("archiv");
  }
  if (ausgewaehlteQueue === "archiv" && tabArchiv.disabled) {
    if (!tabEingang.disabled) queueTabSetzen("eingang");
    else if (!tabZugewiesen.disabled) queueTabSetzen("zugewiesen");
    else if (!tabAlleKategorie.disabled) queueTabSetzen("alle");
  }
}

function queueTabSetzen(queue) {
  ausgewaehlteQueue = queue;
  tabEingang.classList.toggle("active", queue === "eingang");
  tabZugewiesen.classList.toggle("active", queue === "zugewiesen");
  tabAlleKategorie.classList.toggle("active", queue === "alle");
  tabArchiv.classList.toggle("active", queue === "archiv");
}

function justizQueueLaden() {
  if (!ausgewaehlteJustizKategorieId) return;
  if (justizSuchModusAktiv) return;

  if (ausgewaehlteQueue === "eingang") {
    if (tabEingang.disabled) return;
    nuiAufruf("hm_bp:justiz_eingang_laden", { kategorieId: ausgewaehlteJustizKategorieId, limit: 100 });
  } else if (ausgewaehlteQueue === "zugewiesen") {
    if (tabZugewiesen.disabled) return;
    nuiAufruf("hm_bp:justiz_zugewiesen_laden", { kategorieId: ausgewaehlteJustizKategorieId, limit: 100 });
  } else if (ausgewaehlteQueue === "alle") {
    if (tabAlleKategorie.disabled) return;
    nuiAufruf("hm_bp:justiz_alle_kategorie_laden", { kategorieId: ausgewaehlteJustizKategorieId, limit: 100 });
  } else if (ausgewaehlteQueue === "archiv") {
    if (tabArchiv.disabled) return;
    justizSearchMeta.textContent = "Archiv wird geladen…";
    justizSuchModusAktiv = true;
    nuiAufruf("hm_bp:justiz_suchen", {
      kategorieId: ausgewaehlteJustizKategorieId,
      queue: "archiv",
      query: "",
      status: "",
      prio: "",
      dateFrom: "",
      dateTo: "",
      sortBy: justizSortBy.value || "updated_at",
      sortDir: justizSortDir.value || "DESC",
      limit: 100,
      offset: 0
    });
  }
}

function justizVerlaufRendern(timeline) {
  justizVerlauf.innerHTML = "";
  const arr = Array.isArray(timeline) ? timeline : [];
  if (arr.length === 0) {
    justizVerlauf.innerHTML = `<div class="muted">Kein Verlauf.</div>`;
    return;
  }

  for (const e of arr) {
    const meta = `${e.created_at} | ${e.entry_type} | ${e.visibility} | ${e.author_name || "-"}`;
    let text = "";
    try {
      const c = typeof e.content === "string" ? JSON.parse(e.content) : e.content;
      text = c && c.text ? c.text : JSON.stringify(c);
    } catch {
      text = String(e.content || "");
    }

    const div = document.createElement("div");
    div.className = "eintrag";
    div.innerHTML = `<div class="meta">${escapeHtml(meta)}</div><div>${escapeHtml(text)}</div>`;
    justizVerlauf.appendChild(div);
  }
}

// ==========================
// Justiz: Filter UI
// ==========================
function filterSelectsInitialisieren() {
  justizFilterStatus.innerHTML = "";
  const s0 = document.createElement("option");
  s0.value = "";
  s0.textContent = "Alle";
  justizFilterStatus.appendChild(s0);
  for (const s of statusListeAktuell) {
    const o = document.createElement("option");
    o.value = s.id;
    o.textContent = s.label || s.id;
    justizFilterStatus.appendChild(o);
  }

  justizFilterPrio.innerHTML = "";
  const p0 = document.createElement("option");
  p0.value = "";
  p0.textContent = "Alle";
  justizFilterPrio.appendChild(p0);
  for (const p of prioritaetenListe) {
    const o = document.createElement("option");
    o.value = p.id;
    o.textContent = p.label || p.id;
    justizFilterPrio.appendChild(o);
  }
}

async function justizSuchen() {
  fehlerVerstecken();
  if (!ausgewaehlteJustizKategorieId) return fehlerAnzeigen("Bitte wähle zuerst eine Justiz-Kategorie.");

  const payload = {
    kategorieId: ausgewaehlteJustizKategorieId,
    queue: ausgewaehlteQueue,

    query: (justizSearchQuery.value || "").trim(),
    status: justizFilterStatus.value || "",
    prio: justizFilterPrio.value || "",

    dateFrom: justizFilterDateFrom.value || "",
    dateTo: justizFilterDateTo.value || "",

    sortBy: justizSortBy.value || "updated_at",
    sortDir: justizSortDir.value || "DESC",

    limit: 100,
    offset: 0
  };

  justizSuchModusAktiv = true;
  justizSearchMeta.textContent = "Suche läuft…";
  await nuiAufruf("hm_bp:justiz_suchen", payload);
}

// ==========================
// Justiz: Staff & Priorities UI
// ==========================
function bearbeiterSelectFuellen(selectedIdentifier) {
  justizBearbeiterSelect.innerHTML = "";

  const opt0 = document.createElement("option");
  opt0.value = "";
  opt0.textContent = "Bitte Bearbeiter auswählen…";
  justizBearbeiterSelect.appendChild(opt0);

  for (const b of bearbeiterListe) {
    const o = document.createElement("option");
    o.value = b.identifier;

    const onlineTag = b.online ? "ONLINE" : "OFFLINE";
    const jobTag = (b.job || "").toUpperCase();
    o.textContent = `[${onlineTag}] ${b.name} (${jobTag} / Grad ${b.grade})`;

    if (selectedIdentifier && b.identifier === selectedIdentifier) o.selected = true;
    justizBearbeiterSelect.appendChild(o);
  }

  const onlineCount = bearbeiterListe.filter(x => x.online).length;
  justizBearbeiterMeta.textContent = `Bearbeiter: ${bearbeiterListe.length} (online: ${onlineCount})`;
}

function prioritaetenSelectFuellen(current) {
  justizPrioritaetSelect.innerHTML = "";
  for (const p of prioritaetenListe) {
    const o = document.createElement("option");
    o.value = p.id;
    o.textContent = p.label || p.id;
    if (current && p.id === current) o.selected = true;
    justizPrioritaetSelect.appendChild(o);
  }
}

// ==========================
// Justiz: Regeln + Sperre -> Disabled States
// ==========================
function setBearbeitungNachRegeln() {
  const hasAntrag = !!ausgewaehlterJustizAntragId;
  if (!hasAntrag || !aktuellesJustizRegelObjekt) {
    btnJustizUebernehmen.disabled = true;

    justizBearbeiterSelect.disabled = true;
    btnJustizBearbeiterRefresh.disabled = true;
    btnJustizZuweisen.disabled = true;

    btnJustizPrioritaetSetzen.disabled = true;
    justizPrioritaetSelect.disabled = true;

    btnJustizArchivieren.disabled = true;
    justizArchivGrund.disabled = true;

    btnJustizStatusSetzen.disabled = true;
    justizStatusSelect.disabled = true;
    justizStatusKommentar.disabled = true;

    btnJustizInterneNotiz.disabled = true;
    justizInterneNotizText.disabled = true;

    btnJustizOeffentlicheAntwort.disabled = true;
    justizOeffentlicheAntwortText.disabled = true;

    btnJustizRueckfrageStellen.disabled = true;
    justizRueckfrageText.disabled = true;
    return;
  }

  if (gesperrtVonAnderem) {
    btnJustizUebernehmen.disabled = true;

    justizBearbeiterSelect.disabled = true;
    btnJustizBearbeiterRefresh.disabled = true;
    btnJustizZuweisen.disabled = true;

    btnJustizPrioritaetSetzen.disabled = true;
    justizPrioritaetSelect.disabled = true;

    btnJustizArchivieren.disabled = true;
    justizArchivGrund.disabled = true;

    btnJustizStatusSetzen.disabled = true;
    justizStatusSelect.disabled = true;
    justizStatusKommentar.disabled = true;

    btnJustizInterneNotiz.disabled = true;
    justizInterneNotizText.disabled = true;

    btnJustizOeffentlicheAntwort.disabled = true;
    justizOeffentlicheAntwortText.disabled = true;

    btnJustizRueckfrageStellen.disabled = true;
    justizRueckfrageText.disabled = true;
    return;
  }

  const a = (aktuellesJustizRegelObjekt.aktionen || {});

  btnJustizUebernehmen.disabled = !(a.antragUebernehmen === true);

  const zuweisen = (a.zuweisen === true);
  justizBearbeiterSelect.disabled = !zuweisen;
  btnJustizBearbeiterRefresh.disabled = !zuweisen;
  btnJustizZuweisen.disabled = !zuweisen;

  const prio = (a.prioritaetAendern === true);
  btnJustizPrioritaetSetzen.disabled = !prio;
  justizPrioritaetSelect.disabled = !prio;

  const arch = (a.archivieren === true);
  btnJustizArchivieren.disabled = !arch;
  justizArchivGrund.disabled = !arch;

  const status = (a.statusAendern === true);
  btnJustizStatusSetzen.disabled = !status;
  justizStatusSelect.disabled = !status;
  justizStatusKommentar.disabled = !status;

  const note = (a.interneNotizSchreiben === true);
  btnJustizInterneNotiz.disabled = !note;
  justizInterneNotizText.disabled = !note;

  const pub = (a.oeffentlicheAntwortSchreiben === true);
  btnJustizOeffentlicheAntwort.disabled = !pub;
  justizOeffentlicheAntwortText.disabled = !pub;

  const rq = (a.rueckfrageStellen === true);
  btnJustizRueckfrageStellen.disabled = !rq;
  justizRueckfrageText.disabled = !rq;
}

function sperrHinweisSetzen(lock, gesperrtAnderer) {
  aktuellerLock = lock || null;
  gesperrtVonAnderem = !!gesperrtAnderer;

  if (gesperrtVonAnderem && lock) {
    const name = lock.locked_by_name || "Unbekannt";
    const bis = lock.expires_at || "unbekannt";
    justizSperreHinweis.innerHTML =
      `Dieser Antrag wird gerade von <b>${escapeHtml(name)}</b> bearbeitet (Sperre bis: ${escapeHtml(bis)}). ` +
      `Du kannst lesen, aber nicht bearbeiten.`;
    justizSperreHinweis.style.display = "block";
  } else {
    justizSperreHinweis.style.display = "none";
  }

  setBearbeitungNachRegeln();
}

// ==========================
// Statusliste (Justiz)
// ==========================
function statusListeSetzen(liste, aktuellerStatus) {
  justizStatusSelect.innerHTML = "";
  const arr = Array.isArray(liste) ? liste : [];
  statusListeAktuell = arr;

  for (const s of arr) {
    const o = document.createElement("option");
    o.value = s.id;
    o.textContent = s.label || s.id;
    if (aktuellerStatus && s.id === aktuellerStatus) o.selected = true;
    justizStatusSelect.appendChild(o);
  }

  filterSelectsInitialisieren();
}

// ==========================
// Formular-Editor (NEU)
// ==========================
function formEditorHatRechte() {
  const keys = Object.keys(formEditorRechte || {});
  return keys.length > 0;
}

function formEditorRechteFuer(kategorieId) {
  return (formEditorRechte && formEditorRechte[kategorieId]) || { create: false, edit: false, publish: false, archive: false };
}

function formEditorInitKategorieSelect() {
  // Kategorien, für die Rechte existieren
  formEditorKategorieSelect.innerHTML = "";

  const opts = [];

  for (const k of justizKategorien || []) {
    const r = formEditorRechteFuer(k.id);
    if (r.create || r.edit || r.publish || r.archive) {
      opts.push({ id: k.id, name: k.name });
    }
  }

  if (opts.length === 0) {
    formEditorKategorieSelect.disabled = true;
    formEditorMeta.textContent = "Du hast keine Rechte für den Formular-Editor.";
    formEditorBox.style.display = "none";
    return;
  }

  formEditorKategorieSelect.disabled = false;
  for (const o of opts) {
    const opt = document.createElement("option");
    opt.value = o.id;
    opt.textContent = `${o.name} (${o.id})`;
    formEditorKategorieSelect.appendChild(opt);
  }

  // Auswahl setzen
  if (formEditorKategorieId && opts.some(x => x.id === formEditorKategorieId)) {
    formEditorKategorieSelect.value = formEditorKategorieId;
  } else {
    formEditorKategorieId = opts[0].id;
    formEditorKategorieSelect.value = formEditorKategorieId;
  }

  formEditorMeta.textContent = "Formular-Editor bereit.";
  formEditorBox.style.display = "block";

  formEditorLoadFormList();
  updateFormEditorButtons();
}

async function formEditorLoadRechte() {
  formEditorMeta.textContent = "Lade Rechte…";
  formEditorRechte = {};

  // Wir nutzen eine NUI Route; Client.lua muss die POSTs an Server Events weiterleiten.
  // Diese Route wird im nächsten Paket-Serverfile ergänzt: hm_bp:form_editor_rechte_laden
  const res = await nuiAufruf("hm_bp:form_editor_rechte_laden", {});
  if (!res || res.ok !== true) {
    // Fallback: keine Rechte
    formEditorMeta.textContent = "Rechte konnten nicht geladen werden.";
    formEditorBox.style.display = "none";
    return;
  }

  formEditorRechte = res.rechte || {};
  formEditorInitKategorieSelect();
}

async function formEditorLoadFormList() {
  formEditorFormListeState = [];
  listeLeeren(formEditorFormListe);
  formEditorFormHeader.textContent = "Kein Formular ausgewählt.";
  formEditorFormId = null;
  formEditorSchemaDraft = null;
  renderFormEditorFields();
  renderFormEditorPreview();
  updateFormEditorButtons();

  if (!formEditorKategorieId) return;

  const r = formEditorRechteFuer(formEditorKategorieId);
  if (!r.edit && !r.create && !r.publish && !r.archive) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Keine Rechte in dieser Kategorie.";
    formEditorFormListe.appendChild(m);
    return;
  }

  formEditorMeta.textContent = "Formulare werden geladen…";
  const res = await nuiAufruf("hm_bp:form_editor_liste_laden", { kategorieId: formEditorKategorieId });
  if (!res || res.ok !== true) {
    formEditorMeta.textContent = "";
    return fehlerAnzeigen(res?.fehler?.nachricht || "Formularliste konnte nicht geladen werden.");
  }

  formEditorFormListeState = Array.isArray(res.liste) ? res.liste : [];
  formEditorMeta.textContent = `Formulare: ${formEditorFormListeState.length}`;

  renderFormEditorFormList();
}

function statusBadge(status) {
  if (status === "published") return `<span class="badge badge-ok">Veröffentlicht</span>`;
  if (status === "draft") return `<span class="badge badge-warn">Entwurf</span>`;
  if (status === "archived") return `<span class="badge badge-danger">Archiv</span>`;
  return `<span class="badge">${escapeHtml(status || "-")}</span>`;
}

function renderFormEditorFormList() {
  listeLeeren(formEditorFormListe);

  if (!formEditorFormListeState || formEditorFormListeState.length === 0) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Keine DB-Formulare in dieser Kategorie.";
    formEditorFormListe.appendChild(m);
    return;
  }

  for (const f of formEditorFormListeState) {
    const div = itemErstellen({
      name: f.title || f.id,
      desc: `ID: ${f.id} | Status: ${f.status} | Veröffentlicht: ${f.published_version || "-"}`,
      active: formEditorFormId === f.id,
      onclick: async () => {
        formEditorFormId = f.id;
        await formEditorLoadDraftSchema();
        renderFormEditorFormList();
      }
    });
    div.querySelector(".name").innerHTML = `${escapeHtml(f.title || f.id)} ${statusBadge(f.status)}`;
    formEditorFormListe.appendChild(div);
  }
}

function renderFormEditorHeader() {
  if (!formEditorFormId) {
    formEditorFormHeader.textContent = "Kein Formular ausgewählt.";
    return;
  }

  const f = (formEditorFormListeState || []).find(x => x.id === formEditorFormId);
  if (!f) {
    formEditorFormHeader.textContent = `Formular: ${formEditorFormId}`;
    return;
  }
  formEditorFormHeader.innerHTML =
    `Formular: <b>${escapeHtml(f.title || f.id)}</b> (ID: ${escapeHtml(f.id)}) ${statusBadge(f.status)}`;
}

function renderFormEditorFields() {
  listeLeeren(formEditorFeldListe);

  const schema = formEditorSchemaDraft;
  const felder = schema && Array.isArray(schema.felder) ? schema.felder : [];

  if (!formEditorFormId || !schema) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Bitte ein Formular auswählen, um Felder zu bearbeiten.";
    formEditorFeldListe.appendChild(m);
    return;
  }

  if (felder.length === 0) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Keine Felder vorhanden.";
    formEditorFeldListe.appendChild(m);
    return;
  }

  // sort by order
  const arr = [...felder].sort((a, b) => (a.reihenfolge || 999) - (b.reihenfolge || 999));

  for (let i = 0; i < arr.length; i++) {
    const f = arr[i];
    const pf = f.pflicht ? "Pflicht" : "Optional";
    const desc = `Key: ${f.key} | Typ: ${f.typ} | ${pf} | Reihenfolge: ${f.reihenfolge || "-"}`;

    const div = itemErstellen({
      name: f.label || f.key,
      desc,
      active: false,
      onclick: () => {}
    });

    const actions = document.createElement("div");
    actions.className = "mini-actions";

    const btnUp = document.createElement("button");
    btnUp.className = "btn btn-secondary btn-mini";
    btnUp.type = "button";
    btnUp.textContent = "↑";
    btnUp.addEventListener("click", (e) => {
      e.stopPropagation();
      moveField(f.key, -1);
    });

    const btnDown = document.createElement("button");
    btnDown.className = "btn btn-secondary btn-mini";
    btnDown.type = "button";
    btnDown.textContent = "↓";
    btnDown.addEventListener("click", (e) => {
      e.stopPropagation();
      moveField(f.key, +1);
    });

    const btnDel = document.createElement("button");
    btnDel.className = "btn btn-secondary btn-mini";
    btnDel.type = "button";
    btnDel.textContent = "Löschen";
    btnDel.addEventListener("click", (e) => {
      e.stopPropagation();
      deleteField(f.key);
    });

    actions.appendChild(btnUp);
    actions.appendChild(btnDown);
    actions.appendChild(btnDel);

    div.appendChild(actions);
    formEditorFeldListe.appendChild(div);
  }
}

function moveField(key, dir) {
  if (!formEditorSchemaDraft || !Array.isArray(formEditorSchemaDraft.felder)) return;

  const idx = formEditorSchemaDraft.felder.findIndex(x => x.key === key);
  if (idx < 0) return;

  const nidx = idx + dir;
  if (nidx < 0 || nidx >= formEditorSchemaDraft.felder.length) return;

  const tmp = formEditorSchemaDraft.felder[idx];
  formEditorSchemaDraft.felder[idx] = formEditorSchemaDraft.felder[nidx];
  formEditorSchemaDraft.felder[nidx] = tmp;

  // reihenfolge automatisch neu nummerieren
  for (let i = 0; i < formEditorSchemaDraft.felder.length; i++) {
    const f = formEditorSchemaDraft.felder[i];
    f.reihenfolge = i + 1;
  }

  renderFormEditorFields();
  renderFormEditorPreview();
}

function deleteField(key) {
  if (!formEditorSchemaDraft || !Array.isArray(formEditorSchemaDraft.felder)) return;
  formEditorSchemaDraft.felder = formEditorSchemaDraft.felder.filter(x => x.key !== key);
  // reihenfolge neu
  for (let i = 0; i < formEditorSchemaDraft.felder.length; i++) {
    formEditorSchemaDraft.felder[i].reihenfolge = i + 1;
  }
  renderFormEditorFields();
  renderFormEditorPreview();
}

function renderFormEditorPreview() {
  formEditorPreview.innerHTML = "";

  if (!formEditorSchemaDraft || !formEditorFormId) {
    formEditorPreview.innerHTML = `<div class="muted">Keine Vorschau verfügbar.</div>`;
    return;
  }

  const schema = formEditorSchemaDraft;
  const felder = Array.isArray(schema.felder) ? schema.felder : [];
  if (felder.length === 0) {
    formEditorPreview.innerHTML = `<div class="muted">Keine Felder.</div>`;
    return;
  }

  // reuse normal renderer
  for (const feld of felder.sort((a, b) => (a.reihenfolge || 999) - (b.reihenfolge || 999))) {
    formEditorPreview.appendChild(feldElementErstellen(feld));
  }
}

function updateFormEditorButtons() {
  const hasKategorie = !!formEditorKategorieId;
  const r = hasKategorie ? formEditorRechteFuer(formEditorKategorieId) : { create: false, edit: false, publish: false, archive: false };

  btnFormEditorCreate.disabled = !(hasKategorie && r.create === true);

  const hasForm = !!formEditorFormId && !!formEditorSchemaDraft;
  btnFormEditorFieldAdd.disabled = !(hasForm && r.edit === true);
  btnFormEditorSave.disabled = !(hasForm && r.edit === true);
  btnFormEditorPublish.disabled = !(hasForm && r.publish === true);
  btnFormEditorArchive.disabled = !(hasForm && r.archive === true);
}

async function formEditorLoadDraftSchema() {
  formEditorSchemaDraft = null;
  renderFormEditorHeader();
  renderFormEditorFields();
  renderFormEditorPreview();
  updateFormEditorButtons();

  if (!formEditorFormId) return;

  formEditorActionMeta.textContent = "Entwurf wird geladen…";
  const res = await nuiAufruf("hm_bp:form_editor_schema_holen", { formId: formEditorFormId, modus: "draft" });
  if (!res || res.ok !== true) {
    formEditorActionMeta.textContent = "";
    return fehlerAnzeigen(res?.fehler?.nachricht || "Entwurf konnte nicht geladen werden.");
  }

  formEditorSchemaDraft = res.schema;
  renderFormEditorHeader();
  renderFormEditorFields();
  renderFormEditorPreview();
  updateFormEditorButtons();

  formEditorActionMeta.textContent = "Entwurf geladen.";
  setTimeout(() => { if (formEditorActionMeta.textContent === "Entwurf geladen.") formEditorActionMeta.textContent = ""; }, 1500);
}

function buildFieldFromInputs() {
  const key = String(formEditorFieldKey.value || "").trim();
  const typ = normalisiereFeldTyp(String(formEditorFieldTyp.value || "text_short").trim());

  const label = String(formEditorFieldLabel.value || "").trim();
  const placeholder = String(formEditorFieldPlaceholder.value || "").trim();

  const pflicht = String(formEditorFieldPflicht.value || "0") === "1";

  const order = Number(formEditorFieldOrder.value || 0);
  const min = formEditorFieldMin.value === "" ? null : Number(formEditorFieldMin.value);
  const max = formEditorFieldMax.value === "" ? null : Number(formEditorFieldMax.value);

  const regex = String(formEditorFieldRegex.value || "").trim();
  const optionen = parseOptionLines(formEditorFieldOptionen.value || "");

  // Dekorative Felder benötigen kein Label
  const istDekorativ = FELD_TYP_DEKORATIV.has(typ);
  if (!key) return { ok: false, msg: "Key fehlt." };
  if (!label && !istDekorativ) return { ok: false, msg: "Label fehlt." };

  const feld = {
    id: key,
    key,
    label: label || "",
    beschreibung: "",
    typ,
    placeholder: placeholder || undefined,
    pflicht: istDekorativ ? false : pflicht,
    reihenfolge: order > 0 ? order : undefined,
    sichtbarkeit: { buerger: true, justiz: true, nurIntern: false }
  };

  // Typ-spezifische Regeln
  if (typ === "text_short" || typ === "text_long" || typ === "url" ||
      typ === "license_plate" || typ === "player_reference" ||
      typ === "company_reference" || typ === "case_number") {
    if (min !== null && !Number.isNaN(min)) feld.minLaenge = min;
    if (max !== null && !Number.isNaN(max)) feld.maxLaenge = max;
    if (regex) feld.regex = regex;
  } else if (typ === "number" || typ === "amount") {
    if (min !== null && !Number.isNaN(min)) feld.min = min;
    if (max !== null && !Number.isNaN(max)) feld.max = max;
  } else if (FELD_TYP_MIT_OPTIONEN.has(typ)) {
    feld.optionen = optionen;
    if (optionen.length === 0) {
      return { ok: false, msg: `Typ '${typ}' benötigt mindestens eine Option (eine pro Zeile im Optionen-Feld).` };
    }
  }

  return { ok: true, feld };
}

function clearFieldInputs() {
  formEditorFieldKey.value = "";
  formEditorFieldLabel.value = "";
  formEditorFieldPlaceholder.value = "";
  formEditorFieldPflicht.value = "0";
  formEditorFieldOrder.value = "";
  formEditorFieldMin.value = "";
  formEditorFieldMax.value = "";
  formEditorFieldRegex.value = "";
  formEditorFieldOptionen.value = "";
}

function renderFormEditorActionMeta(text, timeoutMs = 2000) {
  formEditorActionMeta.textContent = text || "";
  if (text && timeoutMs > 0) {
    setTimeout(() => {
      if (formEditorActionMeta.textContent === text) formEditorActionMeta.textContent = "";
    }, timeoutMs);
  }
}

// ==========================
// Button bindings
// ==========================
btnClose.addEventListener("click", async () => {
  await nuiAufruf("hm_bp:ui_schliessen", {});
});

btnReload.addEventListener("click", async () => {
  fehlerVerstecken();
  publicIdAusgabe.textContent = "";
  einreichenStatus.textContent = "";
  justizStatusResult.textContent = "";
  justizSearchMeta.textContent = "";
  justizRueckfrageMeta.textContent = "";
  buergerAntwortMeta.textContent = "";
  buergerNachreichenMeta.textContent = "";
  buergerNachreichenUiSetzen(false, null);
  formEditorCreateMeta.textContent = "";
  formEditorFieldAddMeta.textContent = "";
  formEditorActionMeta.textContent = "";

  justizSuchModusAktiv = false;

  await nuiAufruf("hm_bp:portal_daten_anfordern", {});
  await nuiAufruf("hm_bp:kategorien_laden", {});
  await nuiAufruf("hm_bp:meine_antraege_laden", {});
  await nuiAufruf("hm_bp:justiz_kategorien_laden", {});
  await nuiAufruf("hm_bp:prioritaeten_liste_laden", {});
  await nuiAufruf("hm_bp:justiz_bearbeiter_liste_laden", {});

  // Formular-Editor Rechte neu laden
  await formEditorLoadRechte();

  filterSelectsInitialisieren();
});

btnPublicIdTest.addEventListener("click", async () => {
  publicIdAusgabe.textContent = "Bitte warten...";
  await nuiAufruf("hm_bp:debug_oeffentliche_id_test", {});
});

btnEinreichen.addEventListener("click", async () => {
  fehlerVerstecken();
  feldFehlerSetzen({});
  einreichenStatus.textContent = "";

  if (!ausgewaehltesFormularId) return fehlerAnzeigen("Bitte wähle zuerst ein Formular aus.");

  const antworten = antwortenEinsammeln();

  // UI-Helper-Validierung (Client) – sofortiges Feedback
  if (aktuellesSchema) {
    const clientFehler = clientSchemaValidieren(aktuellesSchema, antworten);
    if (Object.keys(clientFehler).length > 0) {
      feldFehlerSetzen(clientFehler);
      einreichenStatus.textContent = "Bitte alle Pflichtfelder korrekt ausfüllen.";
      return;
    }
  }

  einreichenStatus.textContent = "Wird eingereicht...";
  await nuiAufruf("hm_bp:antrag_einreichen", { formularId: ausgewaehltesFormularId, antworten });
});

btnBuergerAntwortSenden.addEventListener("click", async () => {
  fehlerVerstecken();
  if (!ausgewaehlterBuergerAntragId) return fehlerAnzeigen("Bitte wähle links einen Antrag aus.");
  if (!buergerRueckfrageOffen) return fehlerAnzeigen("Keine Rückfrage offen.");

  const text = (buergerAntwortText.value || "").trim();
  if (!text) return fehlerAnzeigen("Antwort ist leer.");

  buergerAntwortMeta.textContent = "Wird gesendet…";
  await nuiAufruf("hm_bp:antrag_buerger_antwort_senden", { antragId: ausgewaehlterBuergerAntragId, text });
});

btnBuergerNachreichen.addEventListener("click", async () => {
  fehlerVerstecken();
  if (!ausgewaehlterBuergerAntragId) return fehlerAnzeigen("Bitte wähle links einen Antrag aus.");
  if (!buergerNachreichungErlaubt) return fehlerAnzeigen("Nachreichen ist derzeit nicht erlaubt.");

  // Felder aus dem Nachreichen-Formular einsammeln
  const inputs = buergerNachreichenFelder.querySelectorAll("[data-key]");
  const felder = {};
  inputs.forEach(wrapper => {
    const key = wrapper.dataset.key;
    if (!key) return;
    const input = wrapper.querySelector("input, textarea, select");
    if (!input || input.disabled) return;
    if (input.type === "checkbox") {
      felder[key] = input.checked;
    } else if (input.multiple) {
      // Multiselect
      const vals = [];
      for (const opt of input.selectedOptions) vals.push(opt.value);
      if (vals.length > 0) felder[key] = vals;
    } else if (input.type === "number") {
      const val = input.value.trim();
      if (val !== "") felder[key] = Number(val);
    } else {
      const val = (input.value || "").trim();
      if (val !== "") felder[key] = val;
    }
  });

  if (Object.keys(felder).length === 0) {
    return fehlerAnzeigen("Keine neuen Werte zum Nachreichen eingegeben.");
  }

  buergerNachreichenMeta.textContent = "Wird nachgereicht…";
  await nuiAufruf("hm_bp:antrag_nachreichen", { antragId: ausgewaehlterBuergerAntragId, felder });
});

btnJustizSuchen.addEventListener("click", async () => {
  await justizSuchen();
});

btnJustizFilterReset.addEventListener("click", () => {
  justizSearchQuery.value = "";
  justizFilterStatus.value = "";
  justizFilterPrio.value = "";
  justizFilterDateFrom.value = "";
  justizFilterDateTo.value = "";
  justizSortBy.value = "updated_at";
  justizSortDir.value = "DESC";
  justizSearchMeta.textContent = "Filter zurückgesetzt.";
  justizSuchModusAktiv = false;
  justizQueueLaden();
});

tabBuerger.addEventListener("click", () => tabSetzen("buerger"));
tabJustiz.addEventListener("click", () => tabSetzen("justiz"));

tabEingang.addEventListener("click", () => {
  if (!tabEingang.disabled) {
    queueTabSetzen("eingang");
    justizSuchModusAktiv = false;
    justizSearchMeta.textContent = "";
    justizQueueLaden();
  }
});
tabZugewiesen.addEventListener("click", () => {
  if (!tabZugewiesen.disabled) {
    queueTabSetzen("zugewiesen");
    justizSuchModusAktiv = false;
    justizSearchMeta.textContent = "";
    justizQueueLaden();
  }
});
tabAlleKategorie.addEventListener("click", () => {
  if (!tabAlleKategorie.disabled) {
    queueTabSetzen("alle");
    justizSuchModusAktiv = false;
    justizSearchMeta.textContent = "";
    justizQueueLaden();
  }
});
tabArchiv.addEventListener("click", () => {
  if (!tabArchiv.disabled) {
    queueTabSetzen("archiv");
    justizSuchModusAktiv = false;
    justizSearchMeta.textContent = "";
    justizQueueLaden();
  }
});

btnJustizBearbeiterRefresh.addEventListener("click", async () => {
  if (btnJustizBearbeiterRefresh.disabled) return;
  justizBearbeiterMeta.textContent = "Liste wird aktualisiert…";
  await nuiAufruf("hm_bp:justiz_bearbeiter_liste_laden", {});
});

btnJustizUebernehmen.addEventListener("click", async () => {
  fehlerVerstecken();
  if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
  if (btnJustizUebernehmen.disabled) return;

  await nuiAufruf("hm_bp:justiz_uebernehmen", { antragId: ausgewaehlterJustizAntragId });
  if (!justizSuchModusAktiv) justizQueueLaden();
  nuiAufruf("hm_bp:justiz_details_laden", { antragId: ausgewaehlterJustizAntragId });
});

btnJustizZuweisen.addEventListener("click", async () => {
  fehlerVerstecken();
  if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
  if (btnJustizZuweisen.disabled) return;

  const zielIdentifier = justizBearbeiterSelect.value;
  if (!zielIdentifier) return fehlerAnzeigen("Bitte wähle einen Bearbeiter aus.");

  const ziel = bearbeiterListe.find(x => x.identifier === zielIdentifier);
  const zielName = ziel ? ziel.name : "";

  await nuiAufruf("hm_bp:justiz_zuweisen", { antragId: ausgewaehlterJustizAntragId, zielIdentifier, zielName });
  if (!justizSuchModusAktiv) justizQueueLaden();
  nuiAufruf("hm_bp:justiz_details_laden", { antragId: ausgewaehlterJustizAntragId });
});

btnJustizPrioritaetSetzen.addEventListener("click", async () => {
  fehlerVerstecken();
  if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
  if (btnJustizPrioritaetSetzen.disabled) return;

  const prio = justizPrioritaetSelect.value;
  await nuiAufruf("hm_bp:justiz_prioritaet_setzen", { antragId: ausgewaehlterJustizAntragId, prio });
  if (!justizSuchModusAktiv) justizQueueLaden();
  nuiAufruf("hm_bp:justiz_details_laden", { antragId: ausgewaehlterJustizAntragId });
});

btnJustizArchivieren.addEventListener("click", async () => {
  fehlerVerstecken();
  if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
  if (btnJustizArchivieren.disabled) return;

  const grund = (justizArchivGrund.value || "").trim();
  await nuiAufruf("hm_bp:justiz_archivieren", { antragId: ausgewaehlterJustizAntragId, grund });
  justizArchivGrund.value = "";
  if (!justizSuchModusAktiv) justizQueueLaden();
  nuiAufruf("hm_bp:justiz_details_laden", { antragId: ausgewaehlterJustizAntragId });
});

btnJustizInterneNotiz.addEventListener("click", async () => {
  fehlerVerstecken();
  if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
  if (btnJustizInterneNotiz.disabled) return;

  const text = justizInterneNotizText.value || "";
  await nuiAufruf("hm_bp:justiz_interne_notiz", { antragId: ausgewaehlterJustizAntragId, text });
  justizInterneNotizText.value = "";
  nuiAufruf("hm_bp:justiz_details_laden", { antragId: ausgewaehlterJustizAntragId });
});

btnJustizOeffentlicheAntwort.addEventListener("click", async () => {
  fehlerVerstecken();
  if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
  if (btnJustizOeffentlicheAntwort.disabled) return;

  const text = justizOeffentlicheAntwortText.value || "";
  await nuiAufruf("hm_bp:justiz_oeffentliche_antwort", { antragId: ausgewaehlterJustizAntragId, text });
  justizOeffentlicheAntwortText.value = "";
  nuiAufruf("hm_bp:justiz_details_laden", { antragId: ausgewaehlterJustizAntragId });
});

btnJustizStatusSetzen.addEventListener("click", async () => {
  fehlerVerstecken();
  if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
  if (btnJustizStatusSetzen.disabled) return;

  const neuerStatus = justizStatusSelect.value;
  const kommentar = justizStatusKommentar.value || "";
  await nuiAufruf("hm_bp:justiz_status_setzen", { antragId: ausgewaehlterJustizAntragId, neuerStatus, kommentar });
  justizStatusKommentar.value = "";
  if (!justizSuchModusAktiv) justizQueueLaden();
  nuiAufruf("hm_bp:justiz_details_laden", { antragId: ausgewaehlterJustizAntragId });
});

btnJustizRueckfrageStellen.addEventListener("click", async () => {
  fehlerVerstecken();
  if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
  if (btnJustizRueckfrageStellen.disabled) return;

  const text = (justizRueckfrageText.value || "").trim();
  if (!text) return fehlerAnzeigen("Rückfragetext ist leer.");

  justizRueckfrageMeta.textContent = "Rückfrage wird gesendet…";
  await nuiAufruf("hm_bp:justiz_rueckfrage_stellen", { antragId: ausgewaehlterJustizAntragId, text });
});

// ===== Formular-Editor Bindings =====
formEditorKategorieSelect.addEventListener("change", async () => {
  formEditorKategorieId = formEditorKategorieSelect.value || null;
  formEditorFormId = null;
  formEditorSchemaDraft = null;
  renderFormEditorHeader();
  renderFormEditorFields();
  renderFormEditorPreview();
  updateFormEditorButtons();
  await formEditorLoadFormList();
});

btnFormEditorCreate.addEventListener("click", async () => {
  fehlerVerstecken();
  formEditorCreateMeta.textContent = "";

  if (btnFormEditorCreate.disabled) return;
  if (!formEditorKategorieId) return fehlerAnzeigen("Bitte zuerst eine Editor-Kategorie wählen.");

  const id = String(formEditorNewId.value || "").trim();
  const titel = String(formEditorNewTitel.value || "").trim();
  const beschreibung = String(formEditorNewBeschreibung.value || "").trim();

  if (!id) return fehlerAnzeigen("Formular-ID fehlt.");
  if (!titel) return fehlerAnzeigen("Titel fehlt.");

  formEditorCreateMeta.textContent = "Formular wird erstellt…";
  const res = await nuiAufruf("hm_bp:form_editor_formular_erstellen", { id, kategorieId: formEditorKategorieId, titel, beschreibung });
  if (!res || res.ok !== true) {
    formEditorCreateMeta.textContent = "";
    return fehlerAnzeigen(res?.fehler?.nachricht || "Formular konnte nicht erstellt werden.");
  }

  formEditorCreateMeta.textContent = "Formular erstellt (Entwurf).";
  formEditorNewId.value = "";
  formEditorNewTitel.value = "";
  formEditorNewBeschreibung.value = "";

  await formEditorLoadFormList();
});

btnFormEditorFieldAdd.addEventListener("click", () => {
  fehlerVerstecken();
  formEditorFieldAddMeta.textContent = "";

  if (btnFormEditorFieldAdd.disabled) return;
  if (!formEditorSchemaDraft) return;

  const built = buildFieldFromInputs();
  if (!built.ok) {
    formEditorFieldAddMeta.textContent = "";
    return fehlerAnzeigen(built.msg);
  }

  const feld = built.feld;
  formEditorSchemaDraft.felder = Array.isArray(formEditorSchemaDraft.felder) ? formEditorSchemaDraft.felder : [];

  // key uniqueness
  if (formEditorSchemaDraft.felder.some(x => x.key === feld.key)) {
    return fehlerAnzeigen("Dieses Feld-Key existiert bereits.");
  }

  // order default
  if (!feld.reihenfolge) {
    feld.reihenfolge = formEditorSchemaDraft.felder.length + 1;
  }

  formEditorSchemaDraft.felder.push(feld);
  clearFieldInputs();

  formEditorFieldAddMeta.textContent = "Feld hinzugefügt (Entwurf – noch nicht gespeichert).";
  renderFormEditorFields();
  renderFormEditorPreview();
});

btnFormEditorSave.addEventListener("click", async () => {
  fehlerVerstecken();
  if (btnFormEditorSave.disabled) return;
  if (!formEditorFormId || !formEditorSchemaDraft) return;

  renderFormEditorActionMeta("Entwurf wird gespeichert…", 0);
  const res = await nuiAufruf("hm_bp:form_editor_schema_speichern", { formId: formEditorFormId, schema: formEditorSchemaDraft });
  if (!res || res.ok !== true) {
    renderFormEditorActionMeta("");
    return fehlerAnzeigen(res?.fehler?.nachricht || "Speichern fehlgeschlagen.");
  }

  renderFormEditorActionMeta(`Entwurf gespeichert. Version: ${res.res?.version || "?"}`);
  await formEditorLoadFormList();
});

btnFormEditorPublish.addEventListener("click", async () => {
  fehlerVerstecken();
  if (btnFormEditorPublish.disabled) return;
  if (!formEditorFormId) return;

  renderFormEditorActionMeta("Veröffentlichung läuft…", 0);
  const res = await nuiAufruf("hm_bp:form_editor_veroeffentlichen", { formId: formEditorFormId });
  if (!res || res.ok !== true) {
    renderFormEditorActionMeta("");
    return fehlerAnzeigen(res?.fehler?.nachricht || "Veröffentlichen fehlgeschlagen.");
  }

  renderFormEditorActionMeta(`Veröffentlicht. Version: ${res.res?.version || "?"}`);
  await formEditorLoadFormList();
});

btnFormEditorArchive.addEventListener("click", async () => {
  fehlerVerstecken();
  if (btnFormEditorArchive.disabled) return;
  if (!formEditorFormId) return;

  renderFormEditorActionMeta("Archivierung läuft…", 0);
  const res = await nuiAufruf("hm_bp:form_editor_archivieren", { formId: formEditorFormId });
  if (!res || res.ok !== true) {
    renderFormEditorActionMeta("");
    return fehlerAnzeigen(res?.fehler?.nachricht || "Archivieren fehlgeschlagen.");
  }

  renderFormEditorActionMeta("Archiviert.");
  await formEditorLoadFormList();
});

// ==========================
// NUI messages
// ==========================
window.addEventListener("message", (event) => {
  const msg = event.data;
  if (!msg || !msg.typ) return;

  if (msg.typ === "hm_bp:ui_oeffnen") {
    app.style.display = "block";
    fehlerVerstecken();
    publicIdAusgabe.textContent = "";
    einreichenStatus.textContent = "";
    tabSetzen("buerger");

    nuiAufruf("hm_bp:prioritaeten_liste_laden", {});
    nuiAufruf("hm_bp:justiz_bearbeiter_liste_laden", {});

    // Formular-Editor Rechte laden
    formEditorLoadRechte();
  }

  if (msg.typ === "hm_bp:ui_schliessen") {
    app.style.display = "none";
  }

  if (msg.typ === "hm_bp:portal:daten_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Keine Berechtigung.");

    const sp = payload.daten?.spieler || {};
    const st = payload.daten?.standort || {};
    aktuellerSpieler = sp;

    spielerName.textContent = sp.name || "-";
    rolle.textContent = sp.rolle || "-";
    jobGrad.textContent = `${sp.jobLabel || sp.job || "-"} (Grad: ${sp.gradLabel || sp.grad || 0})`;
    standortName.textContent = st?.name || "-";

    // Admin-Tab sichtbar/unsichtbar je nach Rolle
    const adminTabEl = document.getElementById("tabAdmin");
    if (adminTabEl) {
      adminTabEl.style.display = (sp.rolle === "admin") ? "" : "none";
    }
  }

  if (msg.typ === "hm_bp:kategorien:liste_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Kategorien konnten nicht geladen werden.");
    kategorienRendern(payload.kategorien);
  }

  if (msg.typ === "hm_bp:formulare:liste_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Formulare konnten nicht geladen werden.");
    formulareRendern(payload.formulare);
  }

  if (msg.typ === "hm_bp:formular:schema_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Formularschema konnte nicht geladen werden.");
    schemaRendern(payload.schema);
  }

  if (msg.typ === "hm_bp:antrag:einreichen_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) {
      einreichenStatus.textContent = "";
      if (payload.fehler?.feldFehler) feldFehlerSetzen(payload.fehler.feldFehler);
      return fehlerAnzeigen(payload.fehler?.nachricht || "Einreichen fehlgeschlagen.");
    }
    einreichenStatus.innerHTML = `<span class="status-ok">Erfolgreich eingereicht:</span> ${escapeHtml(payload.antrag?.public_id)}`;
    nuiAufruf("hm_bp:meine_antraege_laden", {});
  }

  if (msg.typ === "hm_bp:antraege:meine_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Anträge konnten nicht geladen werden.");
    antraegeRendern(payload.antraege);
  }

  if (msg.typ === "hm_bp:prioritaeten:liste_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return;
    prioritaetenListe = payload.liste || [];
    prioritaetenSelectFuellen(null);
    filterSelectsInitialisieren();
  }

  if (msg.typ === "hm_bp:justiz:kategorien_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return;
    justizKategorienRendern(payload.kategorien);
  }

  if (msg.typ === "hm_bp:justiz:bearbeiter_liste_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) {
      justizBearbeiterMeta.textContent = "Bearbeiterliste konnte nicht geladen werden.";
      return;
    }
    bearbeiterListe = payload.liste || [];
    bearbeiterSelectFuellen(null);
  }

  if (msg.typ === "hm_bp:justiz:eigang_antwort" || msg.typ === "hm_bp:justiz:zugewiesen_antwort" || msg.typ === "hm_bp:justiz:alle_kategorie_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Justiz-Liste konnte nicht geladen werden.");
    justizAntraegeRendern(payload.liste);
    justizSearchMeta.textContent = "";
  }

  if (msg.typ === "hm_bp:justiz:suchen_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) {
      justizSearchMeta.textContent = "";
      return fehlerAnzeigen(payload.fehler?.nachricht || "Suche fehlgeschlagen.");
    }

    const res = payload.res || {};
    justizSuchModusAktiv = true;
    justizSearchMeta.textContent = `Gefunden: ${res.total || (res.liste ? res.liste.length : 0)} (zeige: ${res.liste ? res.liste.length : 0})`;
    justizAntraegeRendern(res.liste || []);
  }

  if (msg.typ === "hm_bp:status:liste_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return;
    statusListeSetzen(payload.liste, window.__hm_bp_aktuellerStatus);
  }

  if (msg.typ === "hm_bp:justiz:details_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Details konnten nicht geladen werden.");

    const d = payload.details || {};
    const a = d.antrag || {};
    ausgewaehlterJustizAntragId = a.id;

    aktuellesJustizRegelObjekt = d.regeln || null;
    aktuellerLock = d.sperre || null;
    gesperrtVonAnderem = !!d.gesperrtVonAnderem;

    const buergerName = normName(a.citizen_name);
    justizDetailsHeader.textContent =
      `Antrag: ${a.public_id} | Status: ${a.status} | Priorität: ${a.priority} | Bürger: ${buergerName}`;

    if (aktuellesJustizRegelObjekt && aktuellesJustizRegelObjekt.sehen) {
      setQueueTabsEnabled(aktuellesJustizRegelObjekt.sehen);
    }

    sperrHinweisSetzen(aktuellerLock, gesperrtVonAnderem);

    window.__hm_bp_aktuellerStatus = a.status;
    nuiAufruf("hm_bp:status_liste_laden", { kategorieId: a.category_id });

    prioritaetenSelectFuellen(a.priority);
    if (a.assigned_to_identifier) bearbeiterSelectFuellen(a.assigned_to_identifier);
    else bearbeiterSelectFuellen(null);

    justizStatusResult.textContent = "";
    justizVerlaufRendern(d.timeline || []);

    setBearbeitungNachRegeln();
  }

  if (msg.typ === "hm_bp:justiz:status_setzen_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Status setzen fehlgeschlagen.");
    justizStatusResult.textContent = `Status geändert: ${payload.res?.alt} → ${payload.res?.neu}`;
  }

  if (msg.typ === "hm_bp:justiz:rueckfrage_stellen_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) {
      justizRueckfrageMeta.textContent = "";
      return fehlerAnzeigen(payload.fehler?.nachricht || "Rückfrage stellen fehlgeschlagen.");
    }
    justizRueckfrageMeta.textContent = "Rückfrage gestellt.";
    justizRueckfrageText.value = "";
    if (ausgewaehlterJustizAntragId) {
      nuiAufruf("hm_bp:justiz_details_laden", { antragId: ausgewaehlterJustizAntragId });
    }
  }

if (msg.typ === "hm_bp:antrag:details_mein_antwort") {  
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Details konnten nicht geladen werden.");

    const d = payload.details || {};
    const a = d.antrag || {};

    buergerDetailsHeader.textContent = `Antrag: ${a.public_id} | Status: ${a.status} | Priorität: ${a.priority}`;
    buergerVerlaufRendern(d.timeline || []);
    buergerAntwortUiSetzen(!!d.rueckfrageOffen, null);
    buergerNachreichenUiSetzen(!!d.nachreichungErlaubt, d.payload || null);
  }

  if (msg.typ === "hm_bp:antrag:buerger_antwort_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) {
      buergerAntwortMeta.textContent = "";
      return fehlerAnzeigen(payload.fehler?.nachricht || "Antwort senden fehlgeschlagen.");
    }
    buergerAntwortMeta.textContent = "Antwort gesendet.";
    buergerAntwortText.value = "";
    if (ausgewaehlterBuergerAntragId) {
      nuiAufruf("hm_bp:antrag_details_mein_laden", { antragId: ausgewaehlterBuergerAntragId });
    }
  }

  if (msg.typ === "hm_bp:antrag:nachreichen_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) {
      buergerNachreichenMeta.textContent = "";
      return fehlerAnzeigen(payload.fehler?.nachricht || "Nachreichen fehlgeschlagen.");
    }
    const res = payload.res || {};
    buergerNachreichenMeta.textContent = `Nachgereicht (${res.felderCount || 0} Feld(er)).${res.statusGeaendert ? " Status → " + res.statusNeu : ""}`;
    // Details neu laden, damit die UI aktualisiert wird
    if (ausgewaehlterBuergerAntragId) {
      nuiAufruf("hm_bp:antrag_details_mein_laden", { antragId: ausgewaehlterBuergerAntragId });
    }
  }

  if (msg.typ === "hm_bp:debug:oeffentliche_id_test_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Fehler beim Erzeugen der ID.");
    publicIdAusgabe.textContent = `Neue öffentliche Antragsnummer: ${payload.publicId}`;
  }
});

// ==========================
// Keyboard: ESC closes UI
// ==========================
document.addEventListener("keydown", async (e) => {
  if (e.key === "Escape") await nuiAufruf("hm_bp:ui_schliessen", {});
});

// ==========================
// Admin Panel
// ==========================

// State
let adminAktiveSubsektion = "Standorte"; // Standorte | Kategorien | Formulare | Permissions | Status | Webhooks | Audit

// DOM refs (admin panel)
const tabAdmin            = document.getElementById("tabAdmin");
const bereichAdminContent = document.getElementById("bereichAdminContent");
const adminStatusMeta     = document.getElementById("adminStatusMeta");
const adminPanelBox       = document.getElementById("adminPanelBox");
const adminSektionEditor  = document.getElementById("adminSektionEditor");
const adminAuditPanel     = document.getElementById("adminAuditPanel");
const adminJsonEditor     = document.getElementById("adminJsonEditor");
const adminAktionMeta     = document.getElementById("adminAktionMeta");
const adminAktiveSektionflag = document.getElementById("adminAktiveSektionflag");
const adminGrund          = document.getElementById("adminGrund");
const btnAdminLaden       = document.getElementById("btnAdminLaden");
const btnAdminBasisLaden  = document.getElementById("btnAdminBasisLaden");
const btnAdminOverrideLaden = document.getElementById("btnAdminOverrideLaden");
const btnAdminValidieren  = document.getElementById("btnAdminValidieren");
const btnAdminSpeichern   = document.getElementById("btnAdminSpeichern");
const btnAdminZuruecksetzen = document.getElementById("btnAdminZuruecksetzen");
const btnAdminAuditLaden  = document.getElementById("btnAdminAuditLaden");
const adminAuditListe     = document.getElementById("adminAuditListe");

function adminSubtabSetzen(sektion) {
  adminAktiveSubsektion = sektion;

  // Tab-Highlighting
  document.querySelectorAll(".admin-subtab").forEach(btn => {
    btn.classList.toggle("active", btn.dataset.subtab === sektion);
  });

  if (sektion === "Audit") {
    adminSektionEditor.style.display = "none";
    adminAuditPanel.style.display = "block";
  } else {
    adminSektionEditor.style.display = "block";
    adminAuditPanel.style.display = "none";
    if (adminAktiveSektionflag) adminAktiveSektionflag.textContent = sektion;
    if (adminJsonEditor) adminJsonEditor.value = "";
    if (adminAktionMeta) adminAktionMeta.textContent = "Klicke 'Effektiv laden', 'Basis laden' oder 'Override laden', um die Konfiguration zu bearbeiten.";
  }
}

async function adminPanelLaden() {
  if (!adminStatusMeta) return;
  adminStatusMeta.textContent = "Lade Admin-Panel vom Server…";

  const res = await nuiAufruf("hm_bp:admin_panel_laden", {});
  if (!res || !res.ok) {
    adminStatusMeta.textContent = res?.fehler?.nachricht || "Kein Zugriff auf den Admin-Bereich.";
    if (adminPanelBox) adminPanelBox.style.display = "none";
    return;
  }

  adminStatusMeta.textContent = "";
  if (adminPanelBox) adminPanelBox.style.display = "block";

  // Admin-Tab sichtbar machen
  if (tabAdmin) tabAdmin.style.display = "";

  // Ersten Subtab aktivieren
  adminSubtabSetzen(adminAktiveSubsektion);
}

async function adminSektionLaden(modus) {
  if (!adminSektionEditor) return;
  const sektion = adminAktiveSubsektion;
  if (!adminAktionMeta) return;
  adminAktionMeta.textContent = "Lade Sektion…";

  const res = await nuiAufruf("hm_bp:admin_sektion_laden", { sektion, modus: modus || "effektiv" });
  if (!res || !res.ok) {
    adminAktionMeta.textContent = res?.fehler?.nachricht || "Laden fehlgeschlagen.";
    return;
  }

  try {
    adminJsonEditor.value = JSON.stringify(res.daten, null, 2);
    adminAktionMeta.textContent = `Sektion '${sektion}' geladen (Modus: ${modus || "effektiv"}).`;
  } catch (e) {
    adminAktionMeta.textContent = "Fehler beim Anzeigen der Daten.";
  }
}

async function adminSektionValidieren() {
  const sektion = adminAktiveSubsektion;
  const raw = adminJsonEditor ? adminJsonEditor.value : "";
  if (!raw.trim()) {
    if (adminAktionMeta) adminAktionMeta.textContent = "Editor ist leer. Bitte zuerst Daten laden oder eingeben.";
    return;
  }

  let daten;
  try {
    daten = JSON.parse(raw);
  } catch (e) {
    if (adminAktionMeta) adminAktionMeta.textContent = `JSON-Syntaxfehler: ${e.message}`;
    return;
  }

  if (adminAktionMeta) adminAktionMeta.textContent = "Validierung läuft…";
  const res = await nuiAufruf("hm_bp:admin_sektion_validieren", { sektion, daten });
  if (!res || !res.ok) {
    if (adminAktionMeta) adminAktionMeta.textContent = `Validierungsfehler: ${res?.fehler?.nachricht || "Unbekannter Fehler"}`;
    return;
  }
  if (adminAktionMeta) adminAktionMeta.textContent = res.nachricht || "Validierung erfolgreich.";
}

async function adminSektionSpeichern() {
  const sektion = adminAktiveSubsektion;
  const grund = adminGrund ? adminGrund.value.trim() : "";
  if (!grund) {
    if (adminAktionMeta) adminAktionMeta.textContent = "Bitte einen Grund eingeben (Pflichtfeld).";
    return;
  }

  const raw = adminJsonEditor ? adminJsonEditor.value : "";
  if (!raw.trim()) {
    if (adminAktionMeta) adminAktionMeta.textContent = "Editor ist leer. Bitte zuerst Daten laden oder eingeben.";
    return;
  }

  let daten;
  try {
    daten = JSON.parse(raw);
  } catch (e) {
    if (adminAktionMeta) adminAktionMeta.textContent = `JSON-Syntaxfehler: ${e.message}`;
    return;
  }

  if (adminAktionMeta) adminAktionMeta.textContent = "Speichere…";
  if (btnAdminSpeichern) btnAdminSpeichern.disabled = true;

  const res = await nuiAufruf("hm_bp:admin_sektion_speichern", { sektion, daten, grund });

  if (btnAdminSpeichern) btnAdminSpeichern.disabled = false;

  if (!res || !res.ok) {
    if (adminAktionMeta) adminAktionMeta.textContent = `Fehler: ${res?.fehler?.nachricht || "Speichern fehlgeschlagen."}`;
    return;
  }
  if (adminAktionMeta) adminAktionMeta.textContent = res.nachricht || "Gespeichert.";
  if (adminGrund) adminGrund.value = "";
}

async function adminSektionZuruecksetzen() {
  const sektion = adminAktiveSubsektion;
  const grund = adminGrund ? adminGrund.value.trim() : "";
  if (!grund) {
    if (adminAktionMeta) adminAktionMeta.textContent = "Bitte einen Grund eingeben (Pflichtfeld).";
    return;
  }

  if (!confirm(`Override für Sektion '${sektion}' zurücksetzen? Die Basis-Config wird wieder aktiv.`)) return;

  if (adminAktionMeta) adminAktionMeta.textContent = "Setze zurück…";
  const res = await nuiAufruf("hm_bp:admin_sektion_zuruecksetzen", { sektion, grund });

  if (!res || !res.ok) {
    if (adminAktionMeta) adminAktionMeta.textContent = `Fehler: ${res?.fehler?.nachricht || "Zurücksetzen fehlgeschlagen."}`;
    return;
  }
  if (adminAktionMeta) adminAktionMeta.textContent = res.nachricht || "Override zurückgesetzt.";
  if (adminGrund) adminGrund.value = "";
  adminJsonEditor.value = "";
}

async function adminAuditLogLaden() {
  if (!adminAuditListe) return;
  adminAuditListe.innerHTML = "<div class='muted'>Lade…</div>";

  const res = await nuiAufruf("hm_bp:admin_audit_laden", { limit: 100 });
  adminAuditListe.innerHTML = "";

  if (!res || !res.ok) {
    adminAuditListe.innerHTML = `<div class='muted'>${escapeHtml(res?.fehler?.nachricht || "Audit-Log konnte nicht geladen werden.")}</div>`;
    return;
  }

  const eintraege = res.eintraege || [];
  if (eintraege.length === 0) {
    adminAuditListe.innerHTML = "<div class='muted'>Keine Audit-Einträge vorhanden.</div>";
    return;
  }

  for (const e of eintraege) {
    const div = document.createElement("div");
    div.className = "admin-audit-entry";
    div.innerHTML = `
      <div class="admin-audit-header">
        <span class="admin-audit-ts">${escapeHtml(e.timestamp || "?")}</span>
        <span class="admin-audit-action">${escapeHtml(e.aktion || "?")}</span>
        ${e.sektion ? `<span class="admin-audit-section">${escapeHtml(e.sektion)}</span>` : ""}
      </div>
      <div class="admin-audit-actor">
        ${escapeHtml(e.actor_name || e.actor_identifier || "?")}
        ${e.actor_job ? `(${escapeHtml(e.actor_job)} Grad ${escapeHtml(String(e.actor_grade ?? "?"))})` : ""}
      </div>
      <div class="admin-audit-grund">Grund: ${escapeHtml(e.grund || "-")}</div>
      <div class="admin-audit-id muted">ID: ${escapeHtml(e.request_id || "?")}</div>
    `;
    adminAuditListe.appendChild(div);
  }
}

// Admin-Subtab-Buttons binden
document.querySelectorAll(".admin-subtab").forEach(btn => {
  btn.addEventListener("click", () => adminSubtabSetzen(btn.dataset.subtab));
});

// Admin-Aktion-Buttons binden
if (btnAdminLaden)        btnAdminLaden.addEventListener("click",       () => adminSektionLaden("effektiv"));
if (btnAdminBasisLaden)   btnAdminBasisLaden.addEventListener("click",  () => adminSektionLaden("basis"));
if (btnAdminOverrideLaden) btnAdminOverrideLaden.addEventListener("click", () => adminSektionLaden("override"));
if (btnAdminValidieren)   btnAdminValidieren.addEventListener("click",  () => adminSektionValidieren());
if (btnAdminSpeichern)    btnAdminSpeichern.addEventListener("click",   () => adminSektionSpeichern());
if (btnAdminZuruecksetzen) btnAdminZuruecksetzen.addEventListener("click", () => adminSektionZuruecksetzen());
if (btnAdminAuditLaden)   btnAdminAuditLaden.addEventListener("click",  () => adminAuditLogLaden());

// Admin-Tab-Button binden (nach DOM bereit)
if (tabAdmin) {
  tabAdmin.addEventListener("click", () => {
    tabSetzen("admin");
    adminPanelLaden();
  });
}

// ==========================
// Startup
// ==========================
function startUi() {
  // Editor: Rechte laden, sobald UI geöffnet wird (wird auch in message handler gemacht)
  // Hier nur fallback, falls UI direkt startet:
  formEditorLoadRechte();
  updateFormEditorButtons();
}

startUi();