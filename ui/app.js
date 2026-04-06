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

// PR3: Delegation-Elemente (Bürger-Formular)
const delegationBereich          = document.getElementById("delegationBereich");
const delegationTyp              = document.getElementById("delegationTyp");
const delegationZielBereich      = document.getElementById("delegationZielBereich");
const delegationSuchname         = document.getElementById("delegationSuchname");
const btnDelegationSuchen        = document.getElementById("btnDelegationSuchen");
const delegationSuchMeta         = document.getElementById("delegationSuchMeta");
const delegationSuchergebnisse   = document.getElementById("delegationSuchergebnisse");
const delegationAuswahlAnzeige   = document.getElementById("delegationAuswahlAnzeige");
// PR3: Hilfsantrag-Elemente (Justiz)
const hilfsantragBereich         = document.getElementById("hilfsantragBereich");
const hilfsantragSuchname        = document.getElementById("hilfsantragSuchname");
const btnHilfsantragSuchen       = document.getElementById("btnHilfsantragSuchen");
const hilfsantragSuchMeta        = document.getElementById("hilfsantragSuchMeta");
const hilfsantragSuchergebnisse  = document.getElementById("hilfsantragSuchergebnisse");
const hilfsantragAuswahlAnzeige  = document.getElementById("hilfsantragAuswahlAnzeige");

const btnPublicIdTest = document.getElementById("btnPublicIdTest");
const publicIdAusgabe = document.getElementById("publicIdAusgabe");

const justizKategorienListe = document.getElementById("justizKategorienListe");
const tabEingang = document.getElementById("tabEingang");
const tabZugewiesen = document.getElementById("tabZugewiesen");
const tabAlleKategorie = document.getElementById("tabAlleKategorie");
const tabGenehmigt = document.getElementById("tabGenehmigt");
const tabAbgelehnt = document.getElementById("tabAbgelehnt");
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
const btnJustizNotizEntwurfSpeichern = document.getElementById("btnJustizNotizEntwurfSpeichern");
const btnJustizNotizEntwurfLaden = document.getElementById("btnJustizNotizEntwurfLaden");
const btnJustizNotizEntwurfLoeschen = document.getElementById("btnJustizNotizEntwurfLoeschen");
const justizNotizEntwurfMeta = document.getElementById("justizNotizEntwurfMeta");

const justizOeffentlicheAntwortText = document.getElementById("justizOeffentlicheAntwortText");
const btnJustizOeffentlicheAntwort = document.getElementById("btnJustizOeffentlicheAntwort");

const justizRueckfrageText = document.getElementById("justizRueckfrageText");
const btnJustizRueckfrageStellen = document.getElementById("btnJustizRueckfrageStellen");
const btnJustizRueckfrageEntwurfSpeichern = document.getElementById("btnJustizRueckfrageEntwurfSpeichern");
const btnJustizRueckfrageEntwurfLaden = document.getElementById("btnJustizRueckfrageEntwurfLaden");
const btnJustizRueckfrageEntwurfLoeschen = document.getElementById("btnJustizRueckfrageEntwurfLoeschen");
const justizRueckfrageEntwurfMeta = document.getElementById("justizRueckfrageEntwurfMeta");
const justizRueckfrageMeta = document.getElementById("justizRueckfrageMeta");

const btnJustizPdfExport = document.getElementById("btnJustizPdfExport");
const justizPdfExportMeta = document.getElementById("justizPdfExportMeta");

const justizVerlauf = document.getElementById("justizVerlauf");

// Suche/Filter UI
const justizSearchQuery = document.getElementById("justizSearchQuery");
const justizFilterStatus = document.getElementById("justizFilterStatus");
const justizFilterPrio = document.getElementById("justizFilterPrio");
const justizFilterDateFrom = document.getElementById("justizFilterDateFrom");
const justizFilterDateTo = document.getElementById("justizFilterDateTo");
const justizFilterGebuehr = document.getElementById("justizFilterGebuehr");
const justizFilterFormular = document.getElementById("justizFilterFormular");
const justizSortBy = document.getElementById("justizSortBy");
const justizSortDir = document.getElementById("justizSortDir");
const btnJustizSuchen = document.getElementById("btnJustizSuchen");
const btnJustizFilterReset = document.getElementById("btnJustizFilterReset");
const justizSearchMeta = document.getElementById("justizSearchMeta");

// Bearbeiter / Flags Filter
const justizFilterBearbeiter = document.getElementById("justizFilterBearbeiter");
const justizFilterBearbeiterName = document.getElementById("justizFilterBearbeiterName");
const justizFilterEskaliert = document.getElementById("justizFilterEskaliert");
const justizFilterUeberfaellig = document.getElementById("justizFilterUeberfaellig");

// Paginierung
const justizPaginierung = document.getElementById("justizPaginierung");
const btnJustizSeiteZurueck = document.getElementById("btnJustizSeiteZurueck");
const btnJustizSeiteWeiter = document.getElementById("btnJustizSeiteWeiter");
const justizSeiteInfo = document.getElementById("justizSeiteInfo");
const justizGesamtInfo = document.getElementById("justizGesamtInfo");

// Bürger-Suche UI (PR6)
const buergerSucheQuery    = document.getElementById("buergerSucheQuery");
const buergerSucheStatus   = document.getElementById("buergerSucheStatus");
const buergerSucheDateFrom = document.getElementById("buergerSucheDateFrom");
const buergerSucheDateTo   = document.getElementById("buergerSucheDateTo");
const buergerSucheSortBy   = document.getElementById("buergerSucheSortBy");
const buergerSucheSortDir  = document.getElementById("buergerSucheSortDir");
const btnBuergerSuchen     = document.getElementById("btnBuergerSuchen");
const btnBuergerSucheReset = document.getElementById("btnBuergerSucheReset");
const buergerSucheMeta     = document.getElementById("buergerSucheMeta");
const buergerSuchePaginierung = document.getElementById("buergerSuchePaginierung");
const btnBuergerSeiteZurueck  = document.getElementById("btnBuergerSeiteZurueck");
const btnBuergerSeiteWeiter   = document.getElementById("btnBuergerSeiteWeiter");
const buergerSeiteInfo        = document.getElementById("buergerSeiteInfo");
const buergerGesamtInfo       = document.getElementById("buergerGesamtInfo");
const buergerSuchErgebnisse   = document.getElementById("buergerSuchErgebnisse");


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

// Anhänge UI (Bürger)
const buergerAnhaengeSection       = document.getElementById("buergerAnhaengeSection");
const buergerAnhaengeListe          = document.getElementById("buergerAnhaengeListe");
const buergerAnhaengeMeta           = document.getElementById("buergerAnhaengeMeta");
const buergerAnhangUrl              = document.getElementById("buergerAnhangUrl");
const buergerAnhangTitel            = document.getElementById("buergerAnhangTitel");
const btnBuergerAnhangHinzufuegen   = document.getElementById("btnBuergerAnhangHinzufuegen");
const buergerAnhangHinzufuegenMeta  = document.getElementById("buergerAnhangHinzufuegenMeta");

// Anhänge UI (Justiz)
const justizAnhaengeSection = document.getElementById("justizAnhaengeSection");
const justizAnhaengeListe   = document.getElementById("justizAnhaengeListe");
const justizAnhaengeMeta    = document.getElementById("justizAnhaengeMeta");

// ===== NEU: Formular-Editor UI Elements =====
const formEditorMeta = document.getElementById("formEditorMeta");
const formEditorBox = document.getElementById("formEditorBox");
const formEditorKategorieSelect = document.getElementById("formEditorKategorieSelect");
const formEditorFormListe = document.getElementById("formEditorFormListe");
const formEditorQuelleSelect = document.getElementById("formEditorQuelleSelect");
const formEditorDBSektion = document.getElementById("formEditorDBSektion");
const formEditorConfigSektion = document.getElementById("formEditorConfigSektion");
const formEditorConfigFormListe = document.getElementById("formEditorConfigFormListe");
const formEditorConfigExportBereich = document.getElementById("formEditorConfigExportBereich");
const formEditorConfigFormTitel = document.getElementById("formEditorConfigFormTitel");
const btnFormEditorConfigExport = document.getElementById("btnFormEditorConfigExport");
const formEditorConfigExportMeta = document.getElementById("formEditorConfigExportMeta");
const formEditorConfigExportOutput = document.getElementById("formEditorConfigExportOutput");

const justizBuergerAngabenSection = document.getElementById("justizBuergerAngabenSection");
const justizBuergerAngaben = document.getElementById("justizBuergerAngaben");

const formEditorNewId = document.getElementById("formEditorNewId");
const formEditorNewTitel = document.getElementById("formEditorNewTitel");
const formEditorNewBeschreibung = document.getElementById("formEditorNewBeschreibung");
const formEditorNewFeeEur = document.getElementById("formEditorNewFeeEur");
const btnFormEditorCreate = document.getElementById("btnFormEditorCreate");
const formEditorCreateMeta = document.getElementById("formEditorCreateMeta");

const formEditorFormHeader = document.getElementById("formEditorFormHeader");
const formEditorFeldListe = document.getElementById("formEditorFeldListe");
const formEditorFeeEur = document.getElementById("formEditorFeeEur");

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
let formEditorQuelle = "db"; // "db" oder "config"
let ausgewaehlteConfigFormularId = null; // für Config-Formular-Editor
let aktuelleConfigFormularListe = []; // gecachte Config-Formulare für aktuelle Kategorie

let justizKategorien = [];
let ausgewaehlteJustizKategorieId = null;
let ausgewaehlteQueue = "eingang";
let ausgewaehlterJustizAntragId = null;

let aktuellerSpieler = { rolle: null, identifier: null };
let aktuellesJustizRegelObjekt = null; // { sehen, aktionen }
let aktuellerLock = null;
let gesperrtVonAnderem = false;

// PR3: Delegation State
let delegationAktiviert = false;
let delegationAusgewaehlterSpieler = null; // { source, name }
let hilfsantragAusgewaehlterSpieler = null; // { source, name } für Justiz-Hilfsantrag
let vollmachtAuftraggeberSpieler = null; // { source, name } für Vollmacht anlegen
let vollmachtBevollmaechtigterSpieler = null; // { source, name } für Vollmacht anlegen

let prioritaetenListe = [];
let bearbeiterListe = [];
let statusListeAktuell = [];

let justizSuchModusAktiv = false;
// Paginierungs-State für Suche
let justizSuchAktuelleSeite = 1;
let justizSuchGesamtSeiten = 1;
let justizSuchLetztesPayload = null; // wird für Seitenblättern wiederverwendet

// PR6: Bürger-Suche State
let buergerSucheAktuelleSeite = 1;
let buergerSucheGesamtSeiten = 1;
let buergerSucheLetztesPayload = null;

// PR6: Admin-Ops State
let opsAktuellerSubtab = "suche";
let opsSucheAktuelleSeite = 1;
let opsSucheGesamtSeiten = 1;
let opsSucheLetztesPayload = null;
let opsImAuftragAusgewaehlterSpieler = null; // { source, name }
let opsImAuftragAusgewaehlterFormularId = null;

let ausgewaehlterBuergerAntragId = null;
let buergerRueckfrageOffen = false;
let buergerNachreichungErlaubt = false;
let buergerAktuellerPayload = null; // { fields_snapshot, answers } für Nachreichen
let buergerAnhangHinzufuegenErlaubt = false; // PR8: Anhänge erlaubt in aktuellem Status

// PR8: Status, in denen Bürger Anhänge hinzufügen darf (spiegelt Config.Anhaenge.BuergerErlaubteStatus)
const ANHANG_BUERGER_ERLAUBTE_STATUS = ["submitted", "question_open"];

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

// PR8: Sanitize a URL to only allow safe https:// links (client-side guard).
// Server already validates hosts; this prevents XSS via javascript: or data: URLs.
function sanitizeAnhangUrl(url) {
  const s = String(url || "").trim();
  return s.startsWith("https://") ? s : "";
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

/** Parses a non-negative integer from a string input value. Returns 0 for invalid/negative values. */
function parsePositiveInteger(value) {
  return Math.max(0, Math.floor(parseInt(String(value || "0"), 10) || 0));
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

  // Gebühren-Hinweis anzeigen (PR4/PR14)
  const feeEur = formular.fee_eur || 0;
  const zahlungModus = formular.zahlung_modus || "bei_entscheidung";
  let gebuehrHinweis = document.getElementById("gebuehrHinweis");
  if (!gebuehrHinweis) {
    gebuehrHinweis = document.createElement("div");
    gebuehrHinweis.id = "gebuehrHinweis";
    gebuehrHinweis.className = "zahlung-hinweis";
    felderContainer.parentNode.insertBefore(gebuehrHinweis, felderContainer);
  }
  if (feeEur > 0) {
    const feeInt = parseInt(feeEur, 10) || 0;
    const modusText = zahlungModus === "bei_einreichung"
      ? "Die Geb\u00fchr wird sofort bei Einreichung von Ihrem Bankkonto abgebucht."
      : "Die Geb\u00fchr wird nach Bearbeitung Ihres Antrags von Ihrem Bankkonto abgebucht.";
    gebuehrHinweis.innerHTML =
      `<span class="badge badge-warn">Geb\u00fchr: ${feeInt} \u20ac</span> ` +
      `<span class="muted">${modusText}</span>`;
    gebuehrHinweis.style.display = "block";
  } else {
    gebuehrHinweis.style.display = "none";
  }

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
    const feeBadge = (f.fee_eur && f.fee_eur > 0)
      ? ` <span class="badge badge-warn">${parseInt(f.fee_eur, 10) || 0} \u20ac</span>`
      : "";
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
    div.querySelector(".name").innerHTML = `${escapeHtml(f.titel)}${badge}${feeBadge}`;
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
    const titel = `${a.public_id} (${statusIdZuLabel(a.status)})`;
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
        buergerAnhaengeSection.style.display = "none"; // PR8: reset
        nuiAufruf("hm_bp:antrag_details_mein_laden", { antragId: a.id });
        antraegeRendern(arr);
      }
    }));
  }
}

// ==========================
// Verlauf: Hilfsfunktionen
// ==========================
const EINTRAGSTYP_LABELS = {
  internal_note:  "Interne Notiz",
  public_message: "Öffentliche Nachricht",
  request_info:   "Rückfrage",
  system:         "Systemeintrag",
  status_change:  "Statusänderung",
  nachreichung:   "Nachreichung",
};
const SICHTBARKEIT_LABELS = {
  internal: "intern",
  citizen:  "öffentlich",
};

function eintragtypLabel(typ) {
  return EINTRAGSTYP_LABELS[typ] || typ || "Unbekannt";
}

function sichtbarkeitLabel(vis) {
  return SICHTBARKEIT_LABELS[vis] || vis || "";
}

function verlaufEintragRendern(e, mitSichtbarkeit) {
  let text = "";
  try {
    const c = typeof e.content === "string" ? JSON.parse(e.content) : e.content;
    text = c && c.text ? c.text : JSON.stringify(c);
  } catch {
    text = String(e.content || "");
  }

  const autor = escapeHtml(e.author_name || "System");
  const datum = escapeHtml(e.created_at || "");
  const typLabel = escapeHtml(eintragtypLabel(e.entry_type));
  const visLabel = mitSichtbarkeit && e.visibility ? ` (${escapeHtml(sichtbarkeitLabel(e.visibility))})` : "";

  const div = document.createElement("div");
  div.className = "eintrag";
  div.innerHTML =
    `<div class="meta">${typLabel}${visLabel} – ${autor} – ${datum}</div>` +
    `<div>${escapeHtml(text)}</div>`;
  return div;
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
    buergerVerlauf.appendChild(verlaufEintragRendern(e, false));
  }
}

// Zeigt die eingereichten Antworten des Bürgers als Lesemodus an.
function buergerEingereichtAntwortRendern(payload) {
  const container = document.getElementById("buergerEingereichtAntworten");
  if (!container) return;
  container.innerHTML = "";

  if (!payload) {
    container.innerHTML = `<div class="muted">Keine eingereichten Daten verfügbar.</div>`;
    return;
  }

  let felder = [];
  try {
    felder = Array.isArray(payload.fields_snapshot)
      ? payload.fields_snapshot
      : JSON.parse(payload.fields_snapshot || "[]");
  } catch { felder = []; }

  let antworten = {};
  try {
    antworten = (typeof payload.answers === "object" && payload.answers !== null)
      ? payload.answers
      : JSON.parse(payload.answers || "{}");
  } catch { antworten = {}; }

  if (felder.length === 0 && Object.keys(antworten).length === 0) {
    container.innerHTML = `<div class="muted">Keine Formulardaten gespeichert.</div>`;
    return;
  }

  // Felder aus fields_snapshot in Reihenfolge anzeigen
  const anzeigeFelder = felder.filter(f => f.key && !FELD_TYP_DEKORATIV.has(normalisiereFeldTyp(f.typ)));

  if (anzeigeFelder.length > 0) {
    for (const feld of anzeigeFelder) {
      const wert = antworten[feld.key];
      const wertText = wert === undefined || wert === null
        ? "–"
        : (Array.isArray(wert) ? wert.join(", ") : String(wert));

      const row = document.createElement("div");
      row.style.cssText = "margin-bottom:6px;";
      row.innerHTML =
        `<span style="font-weight:600;">${escapeHtml(feld.label || feld.key)}:</span> ` +
        `<span>${escapeHtml(wertText)}</span>`;
      container.appendChild(row);
    }
  } else {
    // Fallback: alle Antworten ohne Schema anzeigen
    for (const [key, val] of Object.entries(antworten)) {
      const wertText = Array.isArray(val) ? val.join(", ") : String(val ?? "–");
      const row = document.createElement("div");
      row.style.cssText = "margin-bottom:6px;";
      row.innerHTML =
        `<span style="font-weight:600;">${escapeHtml(key)}:</span> ` +
        `<span>${escapeHtml(wertText)}</span>`;
      container.appendChild(row);
    }
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

// ==========================
// PR8: Anhänge – gemeinsame Render-Hilfsfunktion
// ==========================
function anhangElementErstellen(a, mitEntfernenButton) {
  const div = document.createElement("div");
  div.className = "eintrag";

  const isDirekt = !!(a.is_direct_image || a.is_direct_image === 1);
  const rawUrl = sanitizeAnhangUrl(a.url);
  const rawTitel = a.title || rawUrl;

  // Meta-Zeile (nur sichere Werte, keine URLs)
  const metaDiv = document.createElement("div");
  metaDiv.className = "meta";
  metaDiv.textContent = `${a.created_at || ""} | ${a.created_by_role || ""} | ${a.created_by_identifier || ""}`;
  div.appendChild(metaDiv);

  // Link-Zeile: DOM-basiert, kein innerHTML mit URL
  const linkDiv = document.createElement("div");
  const link = document.createElement("a");
  link.href = "#";
  link.className = "anhang-link";
  link.textContent = rawTitel;
  link.title = rawUrl;
  link.addEventListener("click", (e) => {
    e.preventDefault();
  });
  linkDiv.appendChild(link);
  div.appendChild(linkDiv);

  // Vorschau nur bei direktem Bildlink
  if (isDirekt && rawUrl) {
    const previewDiv = document.createElement("div");
    previewDiv.style.marginTop = "4px";
    const img = document.createElement("img");
    try {
      const parsed = new URL(rawUrl);
      if (parsed.protocol === "https:") {
        img.src = parsed.href;
      }
    } catch (_e) {
      // URL ungültig – kein Preview
    }
    img.alt = rawTitel;
    img.style.cssText = "max-width:240px;max-height:160px;border-radius:4px;border:1px solid #444;";
    img.addEventListener("error", () => { img.style.display = "none"; });
    previewDiv.appendChild(img);
    div.appendChild(previewDiv);
  }

  if (mitEntfernenButton) {
    const btnWrap = document.createElement("div");
    btnWrap.style.marginTop = "4px";
    const btn = document.createElement("button");
    btn.className = "btn btn-secondary";
    btn.type = "button";
    btn.textContent = "Anhang entfernen";
    btn.style.fontSize = "0.85em";
    btn.addEventListener("click", () => {
      const grund = prompt("Begründung für Entfernung (optional):");
      nuiAufruf("hm_bp:anhang_entfernen", { anhangId: a.id, grund: grund || "" });
    });
    btnWrap.appendChild(btn);
    div.appendChild(btnWrap);
  }

  return div;
}

// Bürger: Anhänge-Section anzeigen/ausblenden + Liste rendern
function buergerAnhaengeUiSetzen(erlaubt, liste) {
  buergerAnhangHinzufuegenErlaubt = !!erlaubt;
  buergerAnhaengeSection.style.display = "block";
  buergerAnhangHinzufuegenMeta.textContent = "";
  buergerAnhangUrl.value = "";
  buergerAnhangTitel.value = "";

  btnBuergerAnhangHinzufuegen.disabled = !erlaubt;
  buergerAnhangUrl.disabled = !erlaubt;
  buergerAnhangTitel.disabled = !erlaubt;

  if (!erlaubt) {
    buergerAnhaengeMeta.textContent = "Anhänge hinzufügen ist im aktuellen Status nicht möglich.";
  } else {
    buergerAnhaengeMeta.textContent = "Erlaubte Hosts: Imgur, Discord CDN. Nur https-Links.";
  }

  buergerAnhaengeListe.innerHTML = "";
  const arr = Array.isArray(liste) ? liste : [];
  if (arr.length === 0) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Keine Anhänge vorhanden.";
    buergerAnhaengeListe.appendChild(m);
  } else {
    for (const a of arr) {
      buergerAnhaengeListe.appendChild(anhangElementErstellen(a, false));
    }
  }
}

// Justiz: Anhänge-Section anzeigen + Liste rendern + Entfernen-Button
function justizAnhaengeRendern(liste) {
  justizAnhaengeSection.style.display = "block";
  justizAnhaengeMeta.textContent = "";
  justizAnhaengeListe.innerHTML = "";
  const arr = Array.isArray(liste) ? liste : [];
  if (arr.length === 0) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Keine Anhänge vorhanden.";
    justizAnhaengeListe.appendChild(m);
  } else {
    for (const a of arr) {
      justizAnhaengeListe.appendChild(anhangElementErstellen(a, true));
    }
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
        if (justizNotizEntwurfMeta) justizNotizEntwurfMeta.textContent = "";
        if (justizRueckfrageEntwurfMeta) justizRueckfrageEntwurfMeta.textContent = "";
        justizAnhaengeSection.style.display = "none"; // PR8

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


// Übersetzt eine Status-ID in ein lesbares Deutsch-Label.
// Greift zuerst auf die dynamisch geladene statusListeAktuell zurück;
// fällt bei unbekannter ID auf eine statische Zuordnung zurück.
function statusIdZuLabel(statusId) {
  // Dynamisch geladene Liste hat Vorrang
  if (Array.isArray(statusListeAktuell)) {
    const gefunden = statusListeAktuell.find(s => s.id === statusId);
    if (gefunden && gefunden.label) return gefunden.label;
  }

  // Statische Fallback-Tabelle für alle bekannten Status-IDs
  const bekannt = {
    draft:                "Entwurf",
    submitted:            "Eingereicht",
    in_review:            "In Prüfung",
    question_open:        "Rückfrage offen",
    waiting_for_documents:"Warten auf Unterlagen",
    forwarded:            "Weitergeleitet",
    escalated:            "Eskaliert",
    partially_approved:   "Teilweise genehmigt",
    approved:             "Genehmigt",
    rejected:             "Abgelehnt",
    withdrawn:            "Zurückgezogen",
    closed:               "Geschlossen",
    archived:             "Archiviert",
  };
  return bekannt[statusId] || statusId;
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
    const statusLabel = statusIdZuLabel(a.status);
    const ueberfaellig = a.due_state === "overdue"
      || (a.sla_due_at && new Date(a.sla_due_at) < new Date());
    const buergerName = normName(a.citizen_name);
    const desc = `Bürger: ${buergerName} | Priorität: ${a.priority} | Bearbeiter: ${a.assigned_to_name || "-"}`;

    const div = document.createElement("div");
    div.className = "item" + (ausgewaehlterJustizAntragId === a.id ? " active" : "");
    const nameHtml = escapeHtml(`${a.public_id} (${statusLabel})`)
      + (ueberfaellig ? ' <span class="badge badge-danger" title="SLA überschritten">Überfällig</span>' : "");
    div.innerHTML = `<div class="name">${nameHtml}</div><div class="desc">${escapeHtml(desc)}</div>`;
    div.addEventListener("click", () => {
      ausgewaehlterJustizAntragId = a.id;
      justizStatusResult.textContent = "";
      justizRueckfrageMeta.textContent = "";
      if (justizNotizEntwurfMeta) justizNotizEntwurfMeta.textContent = "";
      if (justizRueckfrageEntwurfMeta) justizRueckfrageEntwurfMeta.textContent = "";
      nuiAufruf("hm_bp:justiz_details_laden", { antragId: a.id });
      justizAntraegeRendern(arr);
    });
    justizAntraegeListe.appendChild(div);
  }
}

function setQueueTabsEnabled(sehen) {
  const s = sehen || {};
  tabEingang.disabled = !(s.eingang === true);
  tabZugewiesen.disabled = !(s.zugewiesen === true);
  tabAlleKategorie.disabled = !(s.alleKategorie === true);
  tabGenehmigt.disabled = !(s.genehmigt === true);
  tabAbgelehnt.disabled = !(s.abgelehnt === true);
  tabArchiv.disabled = !(s.archiv === true);

  if (ausgewaehlteQueue === "eingang" && tabEingang.disabled) {
    if (!tabZugewiesen.disabled) queueTabSetzen("zugewiesen");
    else if (!tabAlleKategorie.disabled) queueTabSetzen("alle");
    else if (!tabGenehmigt.disabled) queueTabSetzen("genehmigt");
    else if (!tabAbgelehnt.disabled) queueTabSetzen("abgelehnt");
    else if (!tabArchiv.disabled) queueTabSetzen("archiv");
  }
  if (ausgewaehlteQueue === "zugewiesen" && tabZugewiesen.disabled) {
    if (!tabEingang.disabled) queueTabSetzen("eingang");
    else if (!tabAlleKategorie.disabled) queueTabSetzen("alle");
    else if (!tabGenehmigt.disabled) queueTabSetzen("genehmigt");
    else if (!tabAbgelehnt.disabled) queueTabSetzen("abgelehnt");
    else if (!tabArchiv.disabled) queueTabSetzen("archiv");
  }
  if (ausgewaehlteQueue === "alle" && tabAlleKategorie.disabled) {
    if (!tabEingang.disabled) queueTabSetzen("eingang");
    else if (!tabZugewiesen.disabled) queueTabSetzen("zugewiesen");
    else if (!tabGenehmigt.disabled) queueTabSetzen("genehmigt");
    else if (!tabAbgelehnt.disabled) queueTabSetzen("abgelehnt");
    else if (!tabArchiv.disabled) queueTabSetzen("archiv");
  }
  if (ausgewaehlteQueue === "genehmigt" && tabGenehmigt.disabled) {
    if (!tabEingang.disabled) queueTabSetzen("eingang");
    else if (!tabZugewiesen.disabled) queueTabSetzen("zugewiesen");
    else if (!tabAlleKategorie.disabled) queueTabSetzen("alle");
    else if (!tabAbgelehnt.disabled) queueTabSetzen("abgelehnt");
    else if (!tabArchiv.disabled) queueTabSetzen("archiv");
  }
  if (ausgewaehlteQueue === "abgelehnt" && tabAbgelehnt.disabled) {
    if (!tabEingang.disabled) queueTabSetzen("eingang");
    else if (!tabZugewiesen.disabled) queueTabSetzen("zugewiesen");
    else if (!tabAlleKategorie.disabled) queueTabSetzen("alle");
    else if (!tabGenehmigt.disabled) queueTabSetzen("genehmigt");
    else if (!tabArchiv.disabled) queueTabSetzen("archiv");
  }
  if (ausgewaehlteQueue === "archiv" && tabArchiv.disabled) {
    if (!tabEingang.disabled) queueTabSetzen("eingang");
    else if (!tabZugewiesen.disabled) queueTabSetzen("zugewiesen");
    else if (!tabAlleKategorie.disabled) queueTabSetzen("alle");
    else if (!tabGenehmigt.disabled) queueTabSetzen("genehmigt");
    else if (!tabAbgelehnt.disabled) queueTabSetzen("abgelehnt");
  }
}

function queueTabSetzen(queue) {
  ausgewaehlteQueue = queue;
  tabEingang.classList.toggle("active", queue === "eingang");
  tabZugewiesen.classList.toggle("active", queue === "zugewiesen");
  tabAlleKategorie.classList.toggle("active", queue === "alle");
  tabGenehmigt.classList.toggle("active", queue === "genehmigt");
  tabAbgelehnt.classList.toggle("active", queue === "abgelehnt");
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
  } else if (ausgewaehlteQueue === "genehmigt") {
    if (tabGenehmigt.disabled) return;
    nuiAufruf("hm_bp:justiz_genehmigt_laden", { kategorieId: ausgewaehlteJustizKategorieId, limit: 100 });
  } else if (ausgewaehlteQueue === "abgelehnt") {
    if (tabAbgelehnt.disabled) return;
    nuiAufruf("hm_bp:justiz_abgelehnt_laden", { kategorieId: ausgewaehlteJustizKategorieId, limit: 100 });
  } else if (ausgewaehlteQueue === "archiv") {
    if (tabArchiv.disabled) return;
    justizSearchMeta.textContent = "Archiv wird geladen…";
    justizSuchModusAktiv = true;
    justizSuchAktuelleSeite = 1;
    const archivPayload = {
      kategorieId: ausgewaehlteJustizKategorieId,
      queue: "archiv",
      query: "",
      status: "",
      prio: "",
      dateFrom: "",
      dateTo: "",
      sortBy: justizSortBy.value || "updated_at",
      sortDir: justizSortDir.value || "DESC",
      bearbeiter: "",
      eskaliert: false,
      ueberfaellig: false,
      page: 1,
    };
    justizSuchLetztesPayload = archivPayload;
    nuiAufruf("hm_bp:justiz_suchen", archivPayload);
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
    justizVerlauf.appendChild(verlaufEintragRendern(e, true));
  }
}

function justizBuergerAngabenRendern(payloadRaw) {
  if (!justizBuergerAngabenSection || !justizBuergerAngaben) return;
  justizBuergerAngaben.innerHTML = "";

  if (!payloadRaw) {
    justizBuergerAngabenSection.style.display = "none";
    return;
  }

  let felder = [];
  let antworten = {};

  try {
    felder = Array.isArray(payloadRaw.fields_snapshot)
      ? payloadRaw.fields_snapshot
      : JSON.parse(payloadRaw.fields_snapshot || "[]");
  } catch(e) { felder = []; }

  try {
    antworten = (typeof payloadRaw.answers === "object" && payloadRaw.answers !== null)
      ? payloadRaw.answers
      : JSON.parse(payloadRaw.answers || "{}");
  } catch(e) { antworten = {}; }

  // Nur nicht-dekorative Felder zeigen (kein divider/heading/info ohne Antwort)
  const DEKORATIV = new Set(["divider", "heading", "info"]);
  const anzeigeFelder = felder.filter(f => !DEKORATIV.has(f.typ));

  if (anzeigeFelder.length === 0) {
    justizBuergerAngabenSection.style.display = "none";
    return;
  }

  justizBuergerAngabenSection.style.display = "";

  for (const f of anzeigeFelder) {
    const key = f.key || f.id || "";
    const label = f.label || key;
    const wert = antworten[key];
    let wertText = "";

    if (wert === undefined || wert === null || wert === "") {
      wertText = "–";
    } else if (typeof wert === "boolean") {
      wertText = wert ? "Ja" : "Nein";
    } else if (Array.isArray(wert)) {
      wertText = wert.join(", ");
    } else {
      wertText = String(wert);
    }

    const el = document.createElement("div");
    el.style.cssText = "padding:6px 0; border-bottom:1px solid rgba(255,255,255,0.1);";
    el.innerHTML = `<span style="font-weight:600; color:rgba(255,255,255,0.75); font-size:11px;">${escapeHtml(label)}:</span> <span style="color:#fff;">${escapeHtml(wertText)}</span>`;
    justizBuergerAngaben.appendChild(el);
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

  // PR6: Bürger-Suche Status-Select befüllen
  if (buergerSucheStatus) {
    buergerSucheStatus.innerHTML = "";
    const sb0 = document.createElement("option");
    sb0.value = "";
    sb0.textContent = "Alle Status";
    buergerSucheStatus.appendChild(sb0);
    for (const s of statusListeAktuell) {
      const o = document.createElement("option");
      o.value = s.id;
      o.textContent = s.label || s.id;
      buergerSucheStatus.appendChild(o);
    }
  }

  // PR6: Ops-Suche Status-Select befüllen
  const opsSearchStatusEl = document.getElementById("opsSearchStatus");
  if (opsSearchStatusEl) {
    opsSearchStatusEl.innerHTML = "";
    const so0 = document.createElement("option");
    so0.value = "";
    so0.textContent = "Alle Status";
    opsSearchStatusEl.appendChild(so0);
    for (const s of statusListeAktuell) {
      const o = document.createElement("option");
      o.value = s.id;
      o.textContent = s.label || s.id;
      opsSearchStatusEl.appendChild(o);
    }
  }

  // PR6: Ops Status-Override Select befüllen
  const opsStatusOverrideEl = document.getElementById("opsStatusOverrideSelect");
  if (opsStatusOverrideEl && opsStatusOverrideEl.options.length <= 1) {
    opsStatusOverrideEl.innerHTML = "<option value=\"\">– Bitte Status wählen –</option>";
    for (const s of statusListeAktuell) {
      const o = document.createElement("option");
      o.value = s.id;
      o.textContent = s.label || s.id;
      opsStatusOverrideEl.appendChild(o);
    }
  }
}

// -------------------------------------------------------
// Paginierungssteuerung
// -------------------------------------------------------
function justizPaginierungAktualisieren(total, seite, gesamtSeiten) {
  if (!justizPaginierung) return;
  if (total === 0 || gesamtSeiten <= 1) {
    justizPaginierung.style.display = "none";
    return;
  }
  justizPaginierung.style.display = "flex";
  justizSeiteInfo.textContent = `Seite ${seite} von ${gesamtSeiten}`;
  justizGesamtInfo.textContent = `(${total} Einträge gesamt)`;
  btnJustizSeiteZurueck.disabled = seite <= 1;
  btnJustizSeiteWeiter.disabled = seite >= gesamtSeiten;
}

async function justizSuchen(seite) {
  fehlerVerstecken();
  if (!ausgewaehlteJustizKategorieId) return fehlerAnzeigen("Bitte wähle zuerst eine Justiz-Kategorie.");

  // Bearbeiter-Filter zusammenbauen
  let bearbeiterWert = justizFilterBearbeiter.value || "";
  if (bearbeiterWert === "name") {
    bearbeiterWert = (justizFilterBearbeiterName.value || "").trim();
  }

  const payload = {
    kategorieId: ausgewaehlteJustizKategorieId,
    queue: ausgewaehlteQueue,

    query: (justizSearchQuery.value || "").trim(),
    status: justizFilterStatus.value || "",
    prio: justizFilterPrio.value || "",
    zahlungStatus: (justizFilterGebuehr && justizFilterGebuehr.value) || "",
    formularId: (justizFilterFormular && justizFilterFormular.value.trim()) || "",

    dateFrom: justizFilterDateFrom.value || "",
    dateTo: justizFilterDateTo.value || "",

    sortBy: justizSortBy.value || "updated_at",
    sortDir: justizSortDir.value || "DESC",

    bearbeiter: bearbeiterWert,
    eskaliert: justizFilterEskaliert.checked,
    ueberfaellig: justizFilterUeberfaellig.checked,

    page: (typeof seite === "number" && seite >= 1) ? seite : 1,
  };

  justizSuchAktuelleSeite = payload.page;
  justizSuchLetztesPayload = payload;
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

    const onlineTag = b.online ? "Online" : "Nicht verfügbar";
    const jobTag = (b.job || "").toUpperCase();
    o.textContent = `[${onlineTag}] ${b.name} (${jobTag} / Rang ${b.grade})`;

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
    if (btnJustizNotizEntwurfSpeichern) btnJustizNotizEntwurfSpeichern.disabled = true;
    if (btnJustizNotizEntwurfLaden) btnJustizNotizEntwurfLaden.disabled = true;
    if (btnJustizNotizEntwurfLoeschen) btnJustizNotizEntwurfLoeschen.disabled = true;

    btnJustizOeffentlicheAntwort.disabled = true;
    justizOeffentlicheAntwortText.disabled = true;

    btnJustizRueckfrageStellen.disabled = true;
    justizRueckfrageText.disabled = true;
    if (btnJustizRueckfrageEntwurfSpeichern) btnJustizRueckfrageEntwurfSpeichern.disabled = true;
    if (btnJustizRueckfrageEntwurfLaden) btnJustizRueckfrageEntwurfLaden.disabled = true;
    if (btnJustizRueckfrageEntwurfLoeschen) btnJustizRueckfrageEntwurfLoeschen.disabled = true;
    if (btnJustizPdfExport) btnJustizPdfExport.disabled = true;
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
    if (btnJustizNotizEntwurfSpeichern) btnJustizNotizEntwurfSpeichern.disabled = true;
    if (btnJustizNotizEntwurfLaden) btnJustizNotizEntwurfLaden.disabled = true;
    if (btnJustizNotizEntwurfLoeschen) btnJustizNotizEntwurfLoeschen.disabled = true;

    btnJustizOeffentlicheAntwort.disabled = true;
    justizOeffentlicheAntwortText.disabled = true;

    btnJustizRueckfrageStellen.disabled = true;
    justizRueckfrageText.disabled = true;
    if (btnJustizRueckfrageEntwurfSpeichern) btnJustizRueckfrageEntwurfSpeichern.disabled = true;
    if (btnJustizRueckfrageEntwurfLaden) btnJustizRueckfrageEntwurfLaden.disabled = true;
    if (btnJustizRueckfrageEntwurfLoeschen) btnJustizRueckfrageEntwurfLoeschen.disabled = true;
    // PDF-Export auch bei Sperre erlaubt (nur Lesezugriff nötig)
    if (btnJustizPdfExport) btnJustizPdfExport.disabled = false;
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
  if (btnJustizNotizEntwurfSpeichern) btnJustizNotizEntwurfSpeichern.disabled = !note;
  if (btnJustizNotizEntwurfLaden) btnJustizNotizEntwurfLaden.disabled = !note;
  if (btnJustizNotizEntwurfLoeschen) btnJustizNotizEntwurfLoeschen.disabled = !note;

  const pub = (a.oeffentlicheAntwortSchreiben === true);
  btnJustizOeffentlicheAntwort.disabled = !pub;
  justizOeffentlicheAntwortText.disabled = !pub;

  const rq = (a.rueckfrageStellen === true);
  btnJustizRueckfrageStellen.disabled = !rq;
  justizRueckfrageText.disabled = !rq;
  if (btnJustizRueckfrageEntwurfSpeichern) btnJustizRueckfrageEntwurfSpeichern.disabled = !rq;
  if (btnJustizRueckfrageEntwurfLaden) btnJustizRueckfrageEntwurfLaden.disabled = !rq;
  if (btnJustizRueckfrageEntwurfLoeschen) btnJustizRueckfrageEntwurfLoeschen.disabled = !rq;

  // PDF-Export ist immer erlaubt, solange ein Antrag ausgewählt ist (Justiz/Admin)
  if (btnJustizPdfExport) btnJustizPdfExport.disabled = false;
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

async function formEditorLoadConfigFormList() {
  if (!formEditorConfigFormListe) return;
  aktuelleConfigFormularListe = [];
  listeLeeren(formEditorConfigFormListe);
  if (!formEditorKategorieId) return;

  formEditorMeta.textContent = "Config-Formulare werden geladen…";
  const res = await nuiAufruf("hm_bp:form_editor_config_liste_laden", { kategorieId: formEditorKategorieId });
  if (!res || res.ok !== true) {
    formEditorMeta.textContent = "";
    return fehlerAnzeigen(res?.fehler?.nachricht || "Config-Formularliste konnte nicht geladen werden.");
  }

  aktuelleConfigFormularListe = Array.isArray(res.liste) ? res.liste : [];
  formEditorMeta.textContent = `Config-Formulare: ${aktuelleConfigFormularListe.length}`;
  renderFormEditorConfigFormList();
}

function renderFormEditorConfigFormList() {
  if (!formEditorConfigFormListe) return;
  listeLeeren(formEditorConfigFormListe);

  if (!aktuelleConfigFormularListe || aktuelleConfigFormularListe.length === 0) {
    const m = document.createElement("div");
    m.className = "muted";
    m.textContent = "Keine Config-Formulare in dieser Kategorie.";
    formEditorConfigFormListe.appendChild(m);
    return;
  }

  for (const f of aktuelleConfigFormularListe) {
    const item = document.createElement("div");
    item.className = "liste-item" + (f.id === ausgewaehlteConfigFormularId ? " aktiv" : "");
    item.style.cssText = "cursor:pointer; padding:6px 8px; border-bottom:1px solid #eee;";
    item.innerHTML = `<strong>${escapeHtml(f.titel || f.id)}</strong> <span class="muted" style="font-size:11px;">(Config, ${f.feldAnzahl} Felder)</span>`;
    item.addEventListener("click", () => {
      ausgewaehlteConfigFormularId = f.id;
      if (formEditorConfigFormTitel) formEditorConfigFormTitel.textContent = f.titel || f.id;
      if (formEditorConfigExportBereich) formEditorConfigExportBereich.style.display = "";
      if (formEditorConfigExportOutput) { formEditorConfigExportOutput.style.display = "none"; formEditorConfigExportOutput.value = ""; }
      if (formEditorConfigExportMeta) formEditorConfigExportMeta.textContent = "";
      renderFormEditorConfigFormList(); // re-render to highlight
    });
    formEditorConfigFormListe.appendChild(item);
  }
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
  const feeInt = parseInt(f.fee_eur, 10) || 0;
  const feeStr = feeInt > 0 ? ` <span class="badge badge-warn">${feeInt} \u20ac</span>` : "";
  formEditorFormHeader.innerHTML =
    `Formular: <b>${escapeHtml(f.title || f.id)}</b> (ID: ${escapeHtml(f.id)}) ${statusBadge(f.status)}${feeStr}`;
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
  // Gebühr-Feld synchronisieren (PR14)
  if (formEditorFeeEur) {
    formEditorFeeEur.value = String(formEditorSchemaDraft?.formular?.fee_eur || 0);
  }
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
  buergerAnhaengeSection.style.display = "none"; // PR8
  justizAnhaengeSection.style.display = "none"; // PR8
  formEditorCreateMeta.textContent = "";
  formEditorFieldAddMeta.textContent = "";
  formEditorActionMeta.textContent = "";

  justizSuchModusAktiv = false;

  await nuiAufruf("hm_bp:portal_daten_anfordern", {});
  await nuiAufruf("hm_bp:kategorien_laden", {});
  await nuiAufruf("hm_bp:meine_antraege_laden", {});
  await nuiAufruf("hm_bp:prioritaeten_liste_laden", {});

  const reloadRolle = aktuellerSpieler && aktuellerSpieler.rolle;
  if (reloadRolle === "admin" || reloadRolle === "justiz") {
    await nuiAufruf("hm_bp:justiz_kategorien_laden", {});
    await nuiAufruf("hm_bp:justiz_bearbeiter_liste_laden", {});
    // Formular-Editor Rechte neu laden
    await formEditorLoadRechte();
  }

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

  // PR3: Delegation zusammenbauen
  let delegation = null;
  if (delegationAktiviert && delegationTyp && delegationTyp.value) {
    if (!delegationAusgewaehlterSpieler) {
      einreichenStatus.textContent = "";
      return fehlerAnzeigen("Bitte wähle den Ziel-Spieler für die Delegation aus.");
    }
    delegation = {
      typ: delegationTyp.value,
      ziel_source: delegationAusgewaehlterSpieler.source,
    };
  }

  await nuiAufruf("hm_bp:antrag_einreichen", { formularId: ausgewaehltesFormularId, antworten, delegation });
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

// PR8: Bürger – Anhang hinzufügen
btnBuergerAnhangHinzufuegen.addEventListener("click", async () => {
  fehlerVerstecken();
  if (!ausgewaehlterBuergerAntragId) return fehlerAnzeigen("Bitte wähle links einen Antrag aus.");
  if (!buergerAnhangHinzufuegenErlaubt) return fehlerAnzeigen("Anhänge hinzufügen ist im aktuellen Status nicht möglich.");

  const url = (buergerAnhangUrl.value || "").trim();
  if (!url) return fehlerAnzeigen("Bitte gib eine URL ein.");

  const titel = (buergerAnhangTitel.value || "").trim() || null;
  buergerAnhangHinzufuegenMeta.textContent = "Wird hinzugefügt…";
  await nuiAufruf("hm_bp:anhang_hinzufuegen", { antragId: ausgewaehlterBuergerAntragId, url, titel });
});

btnJustizSuchen.addEventListener("click", async () => {
  await justizSuchen(1);
});

btnJustizFilterReset.addEventListener("click", () => {
  justizSearchQuery.value = "";
  justizFilterStatus.value = "";
  justizFilterPrio.value = "";
  if (justizFilterGebuehr) justizFilterGebuehr.value = "";
  if (justizFilterFormular) justizFilterFormular.value = "";
  justizFilterDateFrom.value = "";
  justizFilterDateTo.value = "";
  justizSortBy.value = "updated_at";
  justizSortDir.value = "DESC";
  if (justizFilterBearbeiter) justizFilterBearbeiter.value = "";
  if (justizFilterBearbeiterName) { justizFilterBearbeiterName.value = ""; justizFilterBearbeiterName.style.display = "none"; }
  if (justizFilterEskaliert) justizFilterEskaliert.checked = false;
  if (justizFilterUeberfaellig) justizFilterUeberfaellig.checked = false;
  justizSearchMeta.textContent = "Filter zurückgesetzt.";
  justizSuchModusAktiv = false;
  justizSuchLetztesPayload = null;
  if (justizPaginierung) justizPaginierung.style.display = "none";
  justizQueueLaden();
});

// Bearbeiter-Name-Feld ein-/ausblenden
if (justizFilterBearbeiter) {
  justizFilterBearbeiter.addEventListener("change", () => {
    if (justizFilterBearbeiterName) {
      justizFilterBearbeiterName.style.display = justizFilterBearbeiter.value === "name" ? "" : "none";
    }
  });
}

// Paginierung – Zurück/Weiter
if (btnJustizSeiteZurueck) {
  btnJustizSeiteZurueck.addEventListener("click", async () => {
    if (justizSuchAktuelleSeite > 1) {
      await justizSuchen(justizSuchAktuelleSeite - 1);
    }
  });
}
if (btnJustizSeiteWeiter) {
  btnJustizSeiteWeiter.addEventListener("click", async () => {
    if (justizSuchAktuelleSeite < justizSuchGesamtSeiten) {
      await justizSuchen(justizSuchAktuelleSeite + 1);
    }
  });
}

tabBuerger.addEventListener("click", () => tabSetzen("buerger"));
tabJustiz.addEventListener("click", () => tabSetzen("justiz"));

tabEingang.addEventListener("click", () => {
  if (!tabEingang.disabled) {
    queueTabSetzen("eingang");
    justizSuchModusAktiv = false;
    justizSearchMeta.textContent = "";
    justizSuchLetztesPayload = null;
    if (justizPaginierung) justizPaginierung.style.display = "none";
    justizQueueLaden();
  }
});
tabZugewiesen.addEventListener("click", () => {
  if (!tabZugewiesen.disabled) {
    queueTabSetzen("zugewiesen");
    justizSuchModusAktiv = false;
    justizSearchMeta.textContent = "";
    justizSuchLetztesPayload = null;
    if (justizPaginierung) justizPaginierung.style.display = "none";
    justizQueueLaden();
  }
});
tabAlleKategorie.addEventListener("click", () => {
  if (!tabAlleKategorie.disabled) {
    queueTabSetzen("alle");
    justizSuchModusAktiv = false;
    justizSearchMeta.textContent = "";
    justizSuchLetztesPayload = null;
    if (justizPaginierung) justizPaginierung.style.display = "none";
    justizQueueLaden();
  }
});
tabArchiv.addEventListener("click", () => {
  if (!tabArchiv.disabled) {
    queueTabSetzen("archiv");
    justizSuchModusAktiv = false;
    justizSearchMeta.textContent = "";
    justizSuchLetztesPayload = null;
    if (justizPaginierung) justizPaginierung.style.display = "none";
    justizQueueLaden();
  }
});
tabGenehmigt.addEventListener("click", () => {
  if (!tabGenehmigt.disabled) {
    queueTabSetzen("genehmigt");
    justizSuchModusAktiv = false;
    justizSearchMeta.textContent = "";
    justizSuchLetztesPayload = null;
    if (justizPaginierung) justizPaginierung.style.display = "none";
    justizQueueLaden();
  }
});
tabAbgelehnt.addEventListener("click", () => {
  if (!tabAbgelehnt.disabled) {
    queueTabSetzen("abgelehnt");
    justizSuchModusAktiv = false;
    justizSearchMeta.textContent = "";
    justizSuchLetztesPayload = null;
    if (justizPaginierung) justizPaginierung.style.display = "none";
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

// Entwurf-Buttons: Interne Notiz
if (btnJustizNotizEntwurfSpeichern) {
  btnJustizNotizEntwurfSpeichern.addEventListener("click", async () => {
    fehlerVerstecken();
    if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
    if (btnJustizNotizEntwurfSpeichern.disabled) return;
    const text = (justizInterneNotizText.value || "").trim();
    if (!text) return fehlerAnzeigen("Entwurfstext ist leer.");
    justizNotizEntwurfMeta.textContent = "Wird gespeichert…";
    nuiAufruf("hm_bp:entwurf_speichern", { antragId: ausgewaehlterJustizAntragId, typ: "internal_note", text });
  });
}

if (btnJustizNotizEntwurfLaden) {
  btnJustizNotizEntwurfLaden.addEventListener("click", async () => {
    fehlerVerstecken();
    if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
    if (btnJustizNotizEntwurfLaden.disabled) return;
    justizNotizEntwurfMeta.textContent = "Entwurf wird geladen…";
    nuiAufruf("hm_bp:entwurf_laden", { antragId: ausgewaehlterJustizAntragId, typ: "internal_note" });
  });
}

if (btnJustizNotizEntwurfLoeschen) {
  btnJustizNotizEntwurfLoeschen.addEventListener("click", async () => {
    fehlerVerstecken();
    if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
    if (btnJustizNotizEntwurfLoeschen.disabled) return;
    justizNotizEntwurfMeta.textContent = "Entwurf wird gelöscht…";
    nuiAufruf("hm_bp:entwurf_loeschen", { antragId: ausgewaehlterJustizAntragId, typ: "internal_note" });
  });
}

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

// Entwurf-Buttons: Rückfrage
if (btnJustizRueckfrageEntwurfSpeichern) {
  btnJustizRueckfrageEntwurfSpeichern.addEventListener("click", async () => {
    fehlerVerstecken();
    if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
    if (btnJustizRueckfrageEntwurfSpeichern.disabled) return;
    const text = (justizRueckfrageText.value || "").trim();
    if (!text) return fehlerAnzeigen("Entwurfstext ist leer.");
    justizRueckfrageEntwurfMeta.textContent = "Wird gespeichert…";
    nuiAufruf("hm_bp:entwurf_speichern", { antragId: ausgewaehlterJustizAntragId, typ: "question", text });
  });
}

if (btnJustizRueckfrageEntwurfLaden) {
  btnJustizRueckfrageEntwurfLaden.addEventListener("click", async () => {
    fehlerVerstecken();
    if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
    if (btnJustizRueckfrageEntwurfLaden.disabled) return;
    justizRueckfrageEntwurfMeta.textContent = "Entwurf wird geladen…";
    nuiAufruf("hm_bp:entwurf_laden", { antragId: ausgewaehlterJustizAntragId, typ: "question" });
  });
}

if (btnJustizRueckfrageEntwurfLoeschen) {
  btnJustizRueckfrageEntwurfLoeschen.addEventListener("click", async () => {
    fehlerVerstecken();
    if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
    if (btnJustizRueckfrageEntwurfLoeschen.disabled) return;
    justizRueckfrageEntwurfMeta.textContent = "Entwurf wird gelöscht…";
    nuiAufruf("hm_bp:entwurf_loeschen", { antragId: ausgewaehlterJustizAntragId, typ: "question" });
  });
}

// PR11: PDF-Export
if (btnJustizPdfExport) {
  btnJustizPdfExport.addEventListener("click", async () => {
    fehlerVerstecken();
    if (!ausgewaehlterJustizAntragId) return fehlerAnzeigen("Kein Antrag ausgewählt.");
    if (btnJustizPdfExport.disabled) return;

    justizPdfExportMeta.textContent = "Exportdaten werden geladen…";
    btnJustizPdfExport.disabled = true;
    await nuiAufruf("hm_bp:export_pdf_starten", { antragId: ausgewaehlterJustizAntragId });
  });
}

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

if (formEditorQuelleSelect) {
  formEditorQuelleSelect.addEventListener("change", async () => {
    formEditorQuelle = formEditorQuelleSelect.value || "db";
    if (formEditorDBSektion) formEditorDBSektion.style.display = formEditorQuelle === "db" ? "" : "none";
    if (formEditorConfigSektion) formEditorConfigSektion.style.display = formEditorQuelle === "config" ? "" : "none";
    if (formEditorConfigExportBereich) formEditorConfigExportBereich.style.display = "none";
    ausgewaehlteConfigFormularId = null;
    if (formEditorQuelle === "config") {
      await formEditorLoadConfigFormList();
    }
  });
}

if (btnFormEditorConfigExport) {
  btnFormEditorConfigExport.addEventListener("click", async () => {
    fehlerVerstecken();
    if (!ausgewaehlteConfigFormularId) return;
    if (formEditorConfigExportMeta) formEditorConfigExportMeta.textContent = "Exportiere…";
    const res = await nuiAufruf("hm_bp:form_editor_config_export", { formId: ausgewaehlteConfigFormularId });
    if (formEditorConfigExportMeta) formEditorConfigExportMeta.textContent = "";
    if (!res || res.ok !== true) {
      return fehlerAnzeigen(res?.fehler?.nachricht || "Export fehlgeschlagen.");
    }
    if (formEditorConfigExportOutput) {
      formEditorConfigExportOutput.style.display = "";
      formEditorConfigExportOutput.value = JSON.stringify(res.daten, null, 2);
    }
    if (formEditorConfigExportMeta) formEditorConfigExportMeta.textContent = "JSON exportiert. Kopiere den Inhalt und übertrage die Felder manuell als Lua-Tabelle in config.lua.";
  });
}

btnFormEditorCreate.addEventListener("click", async () => {
  fehlerVerstecken();
  formEditorCreateMeta.textContent = "";

  if (btnFormEditorCreate.disabled) return;
  if (!formEditorKategorieId) return fehlerAnzeigen("Bitte zuerst eine Editor-Kategorie wählen.");

  const id = String(formEditorNewId.value || "").trim();
  const titel = String(formEditorNewTitel.value || "").trim();
  const beschreibung = String(formEditorNewBeschreibung.value || "").trim();
  const feeEur = parsePositiveInteger(formEditorNewFeeEur?.value);

  if (!id) return fehlerAnzeigen("Formular-ID fehlt.");
  if (!titel) return fehlerAnzeigen("Titel fehlt.");

  formEditorCreateMeta.textContent = "Formular wird erstellt…";
  const res = await nuiAufruf("hm_bp:form_editor_formular_erstellen", { id, kategorieId: formEditorKategorieId, titel, beschreibung, fee_eur: feeEur });
  if (!res || res.ok !== true) {
    formEditorCreateMeta.textContent = "";
    return fehlerAnzeigen(res?.fehler?.nachricht || "Formular konnte nicht erstellt werden.");
  }

  formEditorCreateMeta.textContent = "Formular erstellt (Entwurf).";
  formEditorNewId.value = "";
  formEditorNewTitel.value = "";
  formEditorNewBeschreibung.value = "";
  if (formEditorNewFeeEur) formEditorNewFeeEur.value = "0";

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

  // Gebühr aus Input übernehmen (PR14)
  if (formEditorFeeEur) {
    const fee = parsePositiveInteger(formEditorFeeEur.value);
    formEditorSchemaDraft.formular = formEditorSchemaDraft.formular || {};
    formEditorSchemaDraft.formular.fee_eur = fee;
  }

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

    // Hide role-gated tabs until portal data arrives and role is known
    if (tabJustiz) tabJustiz.style.display = "none";
    const adminTabElInit = document.getElementById("tabAdmin");
    if (adminTabElInit) adminTabElInit.style.display = "none";

    nuiAufruf("hm_bp:prioritaeten_liste_laden", {});
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

    // Justiz-Tab: nur für Justiz und Admin sichtbar (niemals für Bürger)
    if (tabJustiz) {
      tabJustiz.style.display = (sp.rolle === "justiz" || sp.rolle === "admin") ? "" : "none";
    }

    // Admin-Tab: nur für Admins sichtbar (nicht für Justiz oder Bürger)
    const adminTabEl = document.getElementById("tabAdmin");
    if (adminTabEl) {
      const darfAdmin = sp.rolle === "admin";
      adminTabEl.style.display = darfAdmin ? "" : "none";
      // Leadership-Status für interne Prüfungen (SLA/Lock) erhalten,
      // aber Admin-Tab wird nur für echte Admins angezeigt.
      adminIstNurLeitung = (sp.ist_leitung === true) && (sp.rolle !== "admin");
    }

    // PR3: Delegation aktiviert? Bereich anzeigen wenn Spieler Berechtigung hat
    delegationAktiviert = !!(payload.daten?.delegation_aktiviert);
    if (delegationBereich) {
      const darfDelegieren = delegationAktiviert &&
        (sp.rolle === "admin" || sp.rolle === "justiz" || sp.rolle === "buerger");
      delegationBereich.style.display = darfDelegieren ? "" : "none";
    }
    // Hilfsantrag: nur für Justiz/Admin anzeigen wenn Delegation aktiv
    if (hilfsantragBereich) {
      const darfHilfsantrag = delegationAktiviert &&
        (sp.rolle === "admin" || sp.rolle === "justiz");
      hilfsantragBereich.style.display = darfHilfsantrag ? "" : "none";
    }
    // Vollmachten-Tab für Admin anzeigen
    const vollmachtenTab = document.getElementById("adminSubtabVollmachten");
    if (vollmachtenTab) {
      const darfVollmacht = delegationAktiviert && (sp.rolle === "admin");
      vollmachtenTab.style.display = darfVollmacht ? "" : "none";
    }

    // Justiz/Admin: Kategorien, Bearbeiterliste und Formular-Editor-Rechte laden
    if (sp.rolle === "admin" || sp.rolle === "justiz") {
      nuiAufruf("hm_bp:justiz_kategorien_laden", {});
      nuiAufruf("hm_bp:justiz_bearbeiter_liste_laden", {});
      formEditorLoadRechte();
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
    let statusHtml = `<span class="status-ok">Erfolgreich eingereicht:</span> ${escapeHtml(payload.antrag?.public_id || "")}`;
    if (payload.antrag?.befreit) {
      statusHtml += `<div class="zahlung-hinweis befreiung-aktiv" role="note" aria-label="Geb\u00fchrenbefreiung"><span class="badge badge-ok">Geb\u00fchrenbefreiung aktiv</span> F\u00fcr diesen Antrag werden keine Geb\u00fchren erhoben.</div>`;
    } else if (payload.antrag?.zahlung_hinweis) {
      statusHtml += `<div class="zahlung-hinweis muted" role="note" aria-label="Zahlungshinweis">${escapeHtml(payload.antrag.zahlung_hinweis)}</div>`;
    }
    einreichenStatus.innerHTML = statusHtml;
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

  if (msg.typ === "hm_bp:justiz:eingang_antwort" || msg.typ === "hm_bp:justiz:zugewiesen_antwort" || msg.typ === "hm_bp:justiz:alle_kategorie_antwort" || msg.typ === "hm_bp:justiz:genehmigt_antwort" || msg.typ === "hm_bp:justiz:abgelehnt_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Justiz-Liste konnte nicht geladen werden.");
    justizAntraegeRendern(payload.liste);
    justizSearchMeta.textContent = "";
  }

  if (msg.typ === "hm_bp:justiz:suchen_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) {
      justizSearchMeta.textContent = "";
      justizPaginierungAktualisieren(0, 1, 1);
      return fehlerAnzeigen(payload.fehler?.nachricht || "Suche fehlgeschlagen.");
    }

    const res = payload.res || {};
    const total = res.total || 0;
    const seite = res.page || 1;
    const gesamtSeiten = res.gesamtSeiten || 1;
    const perPage = res.perPage || 25;
    const vonZeige = total === 0 ? 0 : (seite - 1) * perPage + 1;
    const bisZeige = Math.min(seite * perPage, total);

    justizSuchModusAktiv = true;
    justizSuchAktuelleSeite = seite;
    justizSuchGesamtSeiten = gesamtSeiten;

    justizSearchMeta.textContent = total === 0
      ? "Keine Ergebnisse."
      : `Zeige ${vonZeige}–${bisZeige} von ${total} Eintrag${total !== 1 ? "en" : ""}`;

    justizPaginierungAktualisieren(total, seite, gesamtSeiten);
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
    const statusLabel = statusIdZuLabel(a.status);
    const ueberfaellig = a.due_state === "overdue"
      || (a.sla_due_at && new Date(a.sla_due_at) < new Date());
    const ueberfaelligHinweis = ueberfaellig ? " | ⚠ Überfällig" : "";
    justizDetailsHeader.textContent =
      `Antrag: ${a.public_id} | Status: ${statusLabel} | Priorität: ${a.priority} | Bürger: ${buergerName}${ueberfaelligHinweis}`;

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

    // Bürger-Angaben (Formularfelder + Antworten) rendern
    justizBuergerAngabenRendern(d.payload);

    // PR8: Anhänge laden
    if (a.id) {
      nuiAufruf("hm_bp:anhaenge_listen", { antragId: a.id });
      justizAnhaengeRendern([]);
    }

    setBearbeitungNachRegeln();
  }

  if (msg.typ === "hm_bp:justiz:status_setzen_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Status setzen fehlgeschlagen.");
    justizStatusResult.textContent = `Status geändert: ${statusIdZuLabel(payload.res?.alt)} → ${statusIdZuLabel(payload.res?.neu)}`;
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

  if (msg.typ === "hm_bp:entwurf:speichern_antwort") {
    const payload = msg.payload || {};
    const isNotiz = (payload.typ === "internal_note");
    const metaEl = isNotiz ? justizNotizEntwurfMeta : justizRueckfrageEntwurfMeta;
    if (!payload.ok) {
      if (metaEl) metaEl.textContent = "";
      return fehlerAnzeigen(payload.fehler?.nachricht || "Entwurf konnte nicht gespeichert werden.");
    }
    const ts = payload.updated_at ? new Date(payload.updated_at).toLocaleString("de-DE") : "";
    if (metaEl) metaEl.textContent = ts ? `Zuletzt gespeichert: ${ts}` : "Entwurf gespeichert.";
  }

  if (msg.typ === "hm_bp:entwurf:laden_antwort") {
    const payload = msg.payload || {};
    const isNotiz = (payload.typ === "internal_note");
    const textEl = isNotiz ? justizInterneNotizText : justizRueckfrageText;
    const metaEl = isNotiz ? justizNotizEntwurfMeta : justizRueckfrageEntwurfMeta;
    if (!payload.ok) {
      if (metaEl) metaEl.textContent = "";
      return fehlerAnzeigen(payload.fehler?.nachricht || "Entwurf konnte nicht geladen werden.");
    }
    if (payload.entwurf) {
      if (textEl) textEl.value = payload.entwurf.text || "";
      const ts = payload.entwurf.updated_at ? new Date(payload.entwurf.updated_at).toLocaleString("de-DE") : "";
      if (metaEl) metaEl.textContent = ts ? `Zuletzt gespeichert: ${ts}` : "Entwurf geladen.";
    } else {
      if (metaEl) metaEl.textContent = "Kein Entwurf vorhanden.";
    }
  }

  if (msg.typ === "hm_bp:entwurf:loeschen_antwort") {
    const payload = msg.payload || {};
    const isNotiz = (payload.typ === "internal_note");
    const metaEl = isNotiz ? justizNotizEntwurfMeta : justizRueckfrageEntwurfMeta;
    if (!payload.ok) {
      if (metaEl) metaEl.textContent = "";
      return fehlerAnzeigen(payload.fehler?.nachricht || "Entwurf konnte nicht gelöscht werden.");
    }
    if (metaEl) metaEl.textContent = payload.geloescht ? "Entwurf gelöscht." : "Kein Entwurf vorhanden.";
  }

if (msg.typ === "hm_bp:antrag:details_mein_antwort") {  
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Details konnten nicht geladen werden.");

    const d = payload.details || {};
    const a = d.antrag || {};

    window.__hm_bp_aktuellerStatus = a.status; // PR8: wird für Anhang-Status-Check benötigt
    buergerDetailsHeader.textContent = `Antrag: ${a.public_id} | Status: ${statusIdZuLabel(a.status)} | Priorität: ${a.priority}`;
    buergerEingereichtAntwortRendern(d.payload || null);
    buergerVerlaufRendern(d.timeline || []);
    buergerAntwortUiSetzen(!!d.rueckfrageOffen, null);
    buergerNachreichenUiSetzen(!!d.nachreichungErlaubt, d.payload || null);

    // PR8: Anhänge laden
    const anhangErlaubt = ANHANG_BUERGER_ERLAUBTE_STATUS.includes(a.status);
    if (ausgewaehlterBuergerAntragId) {
      nuiAufruf("hm_bp:anhaenge_listen", { antragId: ausgewaehlterBuergerAntragId });
      buergerAnhaengeUiSetzen(anhangErlaubt, []);
    }
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

  // PR8: Anhänge-Antworten
  if (msg.typ === "hm_bp:anhaenge_listen_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return; // still zeigen (Liste bleibt leer)
    const liste = payload.liste || [];
    // Entscheiden wer gerade aktiv ist: Bürger oder Justiz
    if (aktuellerSpieler.rolle === "buerger") {
      const statusOk = ANHANG_BUERGER_ERLAUBTE_STATUS.includes(window.__hm_bp_aktuellerStatus);
      buergerAnhaengeUiSetzen(statusOk, liste);
    } else {
      justizAnhaengeRendern(liste);
    }
  }

  if (msg.typ === "hm_bp:anhang_hinzufuegen_antwort") {
    const payload = msg.payload || {};
    buergerAnhangHinzufuegenMeta.textContent = "";
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Anhang konnte nicht hinzugefügt werden.");
    buergerAnhangUrl.value = "";
    buergerAnhangTitel.value = "";
    buergerAnhangHinzufuegenMeta.textContent = "Anhang hinzugefügt.";
    if (ausgewaehlterBuergerAntragId) {
      nuiAufruf("hm_bp:anhaenge_listen", { antragId: ausgewaehlterBuergerAntragId });
    }
  }

  if (msg.typ === "hm_bp:anhang_entfernen_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) return fehlerAnzeigen(payload.fehler?.nachricht || "Anhang konnte nicht entfernt werden.");
    justizAnhaengeMeta.textContent = "Anhang entfernt.";
    if (ausgewaehlterJustizAntragId) {
      nuiAufruf("hm_bp:anhaenge_listen", { antragId: ausgewaehlterJustizAntragId });
    }
  }

  // PR11: PDF-Export Antwort
  if (msg.typ === "hm_bp:export:pdf_daten_antwort") {
    if (btnJustizPdfExport) btnJustizPdfExport.disabled = false;
    const payload = msg.payload || {};
    if (!payload.ok) {
      if (justizPdfExportMeta) justizPdfExportMeta.textContent = "";
      return fehlerAnzeigen(payload.fehler?.nachricht || "PDF-Export fehlgeschlagen.");
    }
    if (justizPdfExportMeta) justizPdfExportMeta.textContent = "PDF wird vorbereitet…";
    pdfExportGenerierenUndDrucken(payload.daten || {});
    setTimeout(() => {
      if (justizPdfExportMeta) justizPdfExportMeta.textContent = "PDF-Druckdialog geöffnet. Discord-Benachrichtigung wurde gesendet.";
    }, 800);
  }
});

// ==========================
// Keyboard: ESC closes UI
// ==========================
document.addEventListener("keydown", async (e) => {
  if (e.key === "Escape") await nuiAufruf("hm_bp:ui_schliessen", {});
});

// ==========================
// PR11: PDF-Export – Generierung via Browser-Druck
// ==========================

function pdfExportGenerierenUndDrucken(daten) {
  const antrag   = daten.antrag   || {};
  const timeline = daten.timeline || [];
  const akteur   = daten.akteur_name || "Unbekannt";
  const jetzt    = new Date().toLocaleString("de-DE");

  const esc = (v) => String(v == null ? "–" : v)
    .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;").replace(/'/g, "&#039;");

  // Timeline-Einträge (alle Sichtbarkeitsstufen – Justiz/Admin sieht alles)
  let verlaufHtml = "";
  for (const eintrag of timeline) {
    let inhalt = "";
    try {
      const c = typeof eintrag.content === "string" ? JSON.parse(eintrag.content) : (eintrag.content || {});
      inhalt = esc(c.text || c.nachricht || JSON.stringify(c));
    } catch (_) {
      inhalt = esc(eintrag.content);
    }
    const vis   = eintrag.visibility === "internal" ? " (intern)" : "";
    const autor = esc(eintrag.author_name || "System");
    const datum = esc(eintrag.created_at || "");
    verlaufHtml += `<div class="verlauf-item">
      <div class="verlauf-meta">${esc(eintragtypLabel(eintrag.entry_type))}${vis} – ${autor} – ${datum}</div>
      <div>${inhalt}</div>
    </div>`;
  }
  if (!verlaufHtml) verlaufHtml = "<p>Kein Verlauf vorhanden.</p>";

  const html = `<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <title>Antragsexport ${esc(antrag.public_id)}</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, Helvetica, sans-serif; font-size: 11pt; color: #222; padding: 20mm; }
    .kopf { border-bottom: 2.5px solid #1a365d; padding-bottom: 12px; margin-bottom: 18px; }
    .branding { font-size: 22pt; font-weight: bold; color: #1a365d; letter-spacing: 1px; }
    .subtitle { font-size: 11pt; color: #555; margin-top: 2px; }
    .aktenzeichen { font-size: 13pt; font-weight: bold; margin-top: 8px; color: #333; }
    h2 { font-size: 12pt; color: #1a365d; border-bottom: 1px solid #bbb; padding-bottom: 3px; margin: 18px 0 8px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 4px; }
    td { padding: 3px 6px; vertical-align: top; font-size: 10.5pt; }
    td.k { font-weight: bold; width: 38%; color: #444; }
    .verlauf-item { margin: 6px 0; padding: 7px 10px; border-left: 3px solid #2f80ed; background: #f5f7fa; font-size: 10pt; }
    .verlauf-meta { font-size: 9pt; color: #666; margin-bottom: 2px; font-weight: bold; }
    .fusszeile { margin-top: 28px; padding-top: 8px; border-top: 1px solid #ccc; font-size: 9pt; color: #888; }
    @media print { @page { margin: 12mm; size: A4; } body { padding: 0; } }
  </style>
</head>
<body>
  <div class="kopf">
    <div class="branding">Justiz Eisenfurt</div>
    <div class="subtitle">Bürgerportal — Antragsexport</div>
    <div class="aktenzeichen">Aktenzeichen: ${esc(antrag.public_id)}</div>
  </div>

  <h2>Antragsdaten</h2>
  <table>
    <tr><td class="k">Aktenzeichen:</td><td>${esc(antrag.public_id)}</td></tr>
    <tr><td class="k">Status:</td><td>${esc(statusIdZuLabel(antrag.status))}</td></tr>
    <tr><td class="k">Priorität:</td><td>${esc(antrag.priority)}</td></tr>
    <tr><td class="k">Antragsteller:</td><td>${esc(antrag.citizen_name)}</td></tr>
    <tr><td class="k">Zugewiesener Bearbeiter:</td><td>${esc(antrag.assigned_to_name)}</td></tr>
    <tr><td class="k">Kategorie:</td><td>${esc(antrag.category_id)}</td></tr>
    <tr><td class="k">Formular:</td><td>${esc(antrag.form_id)}</td></tr>
    <tr><td class="k">Eingereicht am:</td><td>${esc(antrag.created_at)}</td></tr>
    <tr><td class="k">Zuletzt geändert:</td><td>${esc(antrag.updated_at)}</td></tr>
  </table>

  <h2>Verlauf</h2>
  ${verlaufHtml}

  <div class="fusszeile">
    Exportiert von: ${esc(akteur)} &nbsp;|&nbsp; ${esc(jetzt)} &nbsp;|&nbsp; Justiz Eisenfurt Bürgerportal
  </div>

  <script>window.onload = function() { window.print(); };<\/script>
</body>
</html>`;

  const blob    = new Blob([html], { type: "text/html; charset=utf-8" });
  const url     = URL.createObjectURL(blob);
  const iframe  = document.createElement("iframe");
  iframe.style.cssText = "position:fixed;top:-9999px;left:-9999px;width:1px;height:1px;border:none;";
  document.body.appendChild(iframe);
  iframe.onload = () => {
    try {
      iframe.contentWindow.focus();
      iframe.contentWindow.print();
    } catch (e) {
      if (typeof console !== "undefined") console.warn("[hm_bp] PDF-Druckdialog konnte nicht geöffnet werden:", e);
    }
    setTimeout(() => {
      document.body.removeChild(iframe);
      URL.revokeObjectURL(url);
    }, 2000);
  };
  iframe.src = url;
}

// ==========================
// Admin Panel
// ==========================

// State
let adminAktiveSubsektion = "Standorte";
let adminModus = "gefuehrt"; // "gefuehrt" | "erweitert"
let adminCrudBearbeitenId = null;
let adminPanelDaten = {};
// PR12: Audit state
let auditAktuelleSeite = 1;
let auditGesamt = 0;
let adminIstNurLeitung = false; // true wenn Spieler nur Leitung ist (kein Admin)

// DOM refs (admin panel)
const tabAdmin              = document.getElementById("tabAdmin");
const bereichAdminContent   = document.getElementById("bereichAdminContent");
const adminStatusMeta       = document.getElementById("adminStatusMeta");
const adminPanelBox         = document.getElementById("adminPanelBox");
const adminCrudPanel        = document.getElementById("adminCrudPanel");
const adminAuditPanel       = document.getElementById("adminAuditPanel");
const adminJsonEditor       = document.getElementById("adminJsonEditor");
const adminAktionMeta       = document.getElementById("adminAktionMeta");
const adminAktiveSektionflag = document.getElementById("adminAktiveSektionflag");
const adminGrund            = document.getElementById("adminGrund");
const btnAdminLaden         = document.getElementById("btnAdminLaden");
const btnAdminBasisLaden    = document.getElementById("btnAdminBasisLaden");
const btnAdminOverrideLaden = document.getElementById("btnAdminOverrideLaden");
const btnAdminValidieren    = document.getElementById("btnAdminValidieren");
const btnAdminSpeichern     = document.getElementById("btnAdminSpeichern");
const btnAdminZuruecksetzen = document.getElementById("btnAdminZuruecksetzen");
const adminAuditListe       = document.getElementById("adminAuditListe");
// PR12: Audit-Filter + Pagination DOM refs
const auditFilterVon        = document.getElementById("auditFilterVon");
const auditFilterBis        = document.getElementById("auditFilterBis");
const auditFilterActorName  = document.getElementById("auditFilterActorName");
const auditFilterAktion     = document.getElementById("auditFilterAktion");
const auditFilterPublicId   = document.getElementById("auditFilterPublicId");
const auditFilterRequestId  = document.getElementById("auditFilterRequestId");
const btnAuditSuchen        = document.getElementById("btnAuditSuchen");
const btnAuditZurueck       = document.getElementById("btnAuditZurueck");
const btnAuditVorige        = document.getElementById("btnAuditVorige");
const btnAuditNaechste      = document.getElementById("btnAuditNaechste");
const auditSeitenInfo       = document.getElementById("auditSeitenInfo");
const auditProSeite         = document.getElementById("auditProSeite");
const btnAdminModeGefuehrt  = document.getElementById("btnAdminModeGef\u00fchrt");
const btnAdminModeErweitert = document.getElementById("btnAdminModeErweitert");
const adminCrudGefuehrt     = document.getElementById("adminCrudGef\u00fchrt");
const adminCrudErweitert    = document.getElementById("adminCrudErweitert");
const adminCrudListe        = document.getElementById("adminCrudListe");
const adminCrudFormular     = document.getElementById("adminCrudFormular");
const adminCrudFormTitel    = document.getElementById("adminCrudFormTitel");
const adminCrudFormFelder   = document.getElementById("adminCrudFormFelder");
const adminCrudGrund        = document.getElementById("adminCrudGrund");
const adminCrudFormMeta     = document.getElementById("adminCrudFormMeta");
const adminCrudTitel        = document.getElementById("adminCrudTitel");
const btnAdminCrudNeu       = document.getElementById("btnAdminCrudNeu");
const btnAdminCrudAktualisieren = document.getElementById("btnAdminCrudAktualisieren");
const btnAdminCrudSpeichern = document.getElementById("btnAdminCrudSpeichern");
const btnAdminCrudAbbrechen = document.getElementById("btnAdminCrudAbbrechen");

// PR15: JobSettings DOM refs
const adminJobSettingsPanel         = document.getElementById("adminJobSettingsPanel");
const jobSettingsJobListe           = document.getElementById("jobSettingsJobListe");
const jobSettingsGradeListe         = document.getElementById("jobSettingsGradeListe");
const jobSettingsPermGrid           = document.getElementById("jobSettingsPermGrid");
const jobSettingsPermTitel          = document.getElementById("jobSettingsPermTitel");
const jobSettingsMeta               = document.getElementById("jobSettingsMeta");
const jobSettingsGrund              = document.getElementById("jobSettingsGrund");
const btnJobSettingsAktualisieren   = document.getElementById("btnJobSettingsAktualisieren");
const btnJobSettingsSpeichern       = document.getElementById("btnJobSettingsSpeichern");
const btnJobSettingsZuruecksetzen   = document.getElementById("btnJobSettingsZuruecksetzen");
const btnJobSettingsGradeHinzu      = document.getElementById("btnJobSettingsGradeHinzu");
const btnJobSettingsGradeEntf       = document.getElementById("btnJobSettingsGradeEntf");
const jobSettingsNeuerGrade         = document.getElementById("jobSettingsNeuerGrade");
const jobSettingsNeuerGradeName     = document.getElementById("jobSettingsNeuerGradeName");

// PR15: JobSettings state
let jobSettingsDaten          = {};  // aktuell geladene JobSettings (effektiv)
let jobSettingsBasis          = {};  // Basis-Defaults (vor Overrides)
let jobSettingsAktionen       = [];  // kanonische Aktionsschlüssel
let jobSettingsRollenDefaults = {};  // globale Defaults pro Rolle
let jobSettingsPermKatalog    = {};  // Katalog: permission key → { label_de, group_de }
let jobSettingsAktivJob       = null;
let jobSettingsAktivGrade     = null;

// -------------------------------------------------------
// Modus-Umschalter: Gef\u00fchrt <-> Erweitert (JSON)
// -------------------------------------------------------

function adminModusSetzen(modus) {
  adminModus = modus;
  if (btnAdminModeGefuehrt)  btnAdminModeGefuehrt.classList.toggle("active-mode",  modus === "gefuehrt");
  if (btnAdminModeErweitert) btnAdminModeErweitert.classList.toggle("active-mode", modus === "erweitert");
  if (adminCrudGefuehrt)     adminCrudGefuehrt.style.display  = (modus === "gefuehrt")   ? "" : "none";
  if (adminCrudErweitert)    adminCrudErweitert.style.display = (modus === "erweitert") ? "" : "none";
  if (modus === "erweitert") {
    if (adminAktiveSektionflag) adminAktiveSektionflag.textContent = adminAktiveSubsektion;
    if (adminAktionMeta) adminAktionMeta.textContent = "Klicke 'Effektiv laden', 'Basis laden' oder 'Override laden', um die Konfiguration zu bearbeiten.";
  }
}

// -------------------------------------------------------
// Sub-Tab setzen
// -------------------------------------------------------

function adminSubtabSetzen(sektion) {
  adminAktiveSubsektion = sektion;
  document.querySelectorAll(".admin-subtab").forEach(btn => {
    btn.classList.toggle("active", btn.dataset.subtab === sektion);
  });

  // PR3: Vollmachten-Panel
  const vollmachtenPanelEl = document.getElementById("adminVollmachtenPanel");
  // PR6: Ops-Panel
  const opsPanelEl = document.getElementById("adminOpsPanel");

  if (sektion === "Audit") {
    if (adminCrudPanel)         adminCrudPanel.style.display         = "none";
    if (adminAuditPanel)        adminAuditPanel.style.display        = "block";
    if (adminJobSettingsPanel)  adminJobSettingsPanel.style.display  = "none";
    if (vollmachtenPanelEl)     vollmachtenPanelEl.style.display     = "none";
    if (opsPanelEl)             opsPanelEl.style.display             = "none";
    auditListeLaden(1);
  } else if (sektion === "JobSettings") {
    if (adminCrudPanel)         adminCrudPanel.style.display         = "none";
    if (adminAuditPanel)        adminAuditPanel.style.display        = "none";
    if (adminJobSettingsPanel)  adminJobSettingsPanel.style.display  = "block";
    if (vollmachtenPanelEl)     vollmachtenPanelEl.style.display     = "none";
    if (opsPanelEl)             opsPanelEl.style.display             = "none";
    adminJobSettingsLaden();
  } else if (sektion === "Vollmachten") {
    if (adminCrudPanel)         adminCrudPanel.style.display         = "none";
    if (adminAuditPanel)        adminAuditPanel.style.display        = "none";
    if (adminJobSettingsPanel)  adminJobSettingsPanel.style.display  = "none";
    if (vollmachtenPanelEl)     vollmachtenPanelEl.style.display     = "block";
    if (opsPanelEl)             opsPanelEl.style.display             = "none";
    vollmachtenListeLaden();
  } else if (sektion === "Ops") {
    if (adminCrudPanel)         adminCrudPanel.style.display         = "none";
    if (adminAuditPanel)        adminAuditPanel.style.display        = "none";
    if (adminJobSettingsPanel)  adminJobSettingsPanel.style.display  = "none";
    if (vollmachtenPanelEl)     vollmachtenPanelEl.style.display     = "none";
    if (opsPanelEl)             opsPanelEl.style.display             = "block";
    opsSubtabSetzen("suche");
  } else {
    if (adminCrudPanel)         adminCrudPanel.style.display         = "block";
    if (adminAuditPanel)        adminAuditPanel.style.display        = "none";
    if (adminJobSettingsPanel)  adminJobSettingsPanel.style.display  = "none";
    if (vollmachtenPanelEl)     vollmachtenPanelEl.style.display     = "none";
    if (opsPanelEl)             opsPanelEl.style.display             = "none";
    adminFormularAusblenden();
    adminModusSetzen(adminModus);
    if (adminAktiveSektionflag) adminAktiveSektionflag.textContent = sektion;
    // Zeige/verstecke "Neu anlegen"-Button nur für geeignete Sektionen
    const neuErlaubt = ["Standorte", "Kategorien", "Formulare"].includes(sektion);
    if (btnAdminCrudNeu) btnAdminCrudNeu.style.display = neuErlaubt ? "" : "none";
    adminCrudListeAktualisieren();
  }
}

// -------------------------------------------------------
// Panel laden (beim Öffnen des Admin-Tabs)
// -------------------------------------------------------

async function adminPanelLaden() {
  if (!adminStatusMeta) return;

  // Justiz-Leitung: nur Audit-Tab (+ Vollmachten wenn Delegation aktiviert)
  if (adminIstNurLeitung) {
    if (adminPanelBox) adminPanelBox.style.display = "block";
    if (adminStatusMeta) adminStatusMeta.textContent = "";
    // Nicht-Audit-Subtabs für Leitung ausblenden, außer Vollmachten wenn aktiv
    document.querySelectorAll(".admin-subtab").forEach(btn => {
      const subtab = btn.dataset.subtab;
      if (subtab === "Audit") {
        btn.style.display = "";
      } else if (subtab === "Vollmachten" && delegationAktiviert) {
        btn.style.display = "";
      } else {
        btn.style.display = "none";
      }
    });
    adminAktiveSubsektion = "Audit";
    adminSubtabSetzen("Audit"); // loads audit list
    return;
  }

  adminStatusMeta.textContent = "Lade Admin-Panel vom Server...";

  const res = await nuiAufruf("hm_bp:admin_panel_laden", {});
  if (!res || !res.ok) {
    adminStatusMeta.textContent = res?.fehler?.nachricht || "Kein Zugriff auf den Admin-Bereich.";
    if (adminPanelBox) adminPanelBox.style.display = "none";
    return;
  }

  adminStatusMeta.textContent = "";
  adminPanelDaten = res.sektionen || {};
  if (adminPanelBox) adminPanelBox.style.display = "block";
  if (tabAdmin) tabAdmin.style.display = "";

  // PR3: Vollmachten-Tab sichtbar machen wenn Delegation aktiv
  const vollmachtenTabEl = document.getElementById("adminSubtabVollmachten");
  if (vollmachtenTabEl) {
    vollmachtenTabEl.style.display = delegationAktiviert ? "" : "none";
  }

  adminSubtabSetzen(adminAktiveSubsektion);
}

// -------------------------------------------------------
// CRUD: Liste aktualisieren
// -------------------------------------------------------

async function adminCrudListeAktualisieren() {
  if (!adminCrudListe) return;
  const sektion = adminAktiveSubsektion;

  const res = await nuiAufruf("hm_bp:admin_sektion_laden", { sektion, modus: "effektiv" });
  if (!res || !res.ok) {
    adminCrudListe.innerHTML = "<div class='muted'>" + escapeHtml(res?.fehler?.nachricht || "Laden fehlgeschlagen.") + "</div>";
    return;
  }

  const daten = res.daten || {};
  adminPanelDaten[sektion] = daten;

  if (adminCrudTitel) adminCrudTitel.textContent = sektion;

  if (sektion === "Module")      { adminModulAnzeigen(daten);      return; }
  if (sektion === "Webhooks")    { adminWebhooksAnzeigen(daten);   return; }
  if (sektion === "Permissions") { adminPermissionsAnzeigen(daten); return; }
  if (sektion === "Status")      { adminStatusAnzeigen(daten);     return; }

  // Generische Listen-Ansicht f\u00fcr Standorte, Kategorien, Formulare
  const liste = daten.Liste || {};
  adminCrudListe.innerHTML = "";

  const eintraege = Object.entries(liste);
  if (eintraege.length === 0) {
    adminCrudListe.innerHTML = "<div class='muted'>Keine Eintr\u00e4ge vorhanden. Klicke '+ Neu anlegen'.</div>";
    return;
  }

  eintraege.sort((a, b) => {
    const sa = a[1].sortierung ?? 9999;
    const sb = b[1].sortierung ?? 9999;
    if (sa !== sb) return sa - sb;
    return (a[1].name || a[0]).localeCompare(b[1].name || b[0]);
  });

  for (const [id, entity] of eintraege) {
    const div = document.createElement("div");
    div.className = "admin-crud-item";

    const statusBadge = adminEntityBadge(sektion, entity);
    const metaText    = adminEntityMeta(sektion, entity);

    div.innerHTML = `
      <div class="admin-crud-item-info">
        <div class="admin-crud-item-name">${escapeHtml(entity.name || id)}</div>
        <div class="admin-crud-item-id">${escapeHtml(id)}</div>
        ${metaText ? `<div class="admin-crud-item-meta">${escapeHtml(metaText)}</div>` : ""}
      </div>
      ${statusBadge}
      <div class="admin-crud-item-actions">
        ${adminEntityAktionen(sektion, id, entity)}
      </div>
    `;

    div.querySelectorAll("[data-aktion]").forEach(btn => {
      btn.addEventListener("click", () => adminCrudAktionAusfuehren(btn.dataset.aktion, id, entity));
    });

    adminCrudListe.appendChild(div);
  }
}

function adminEntityBadge(sektion, entity) {
  if (sektion === "Formulare") {
    const status = entity.status || "entwurf";
    const cls   = { entwurf: "badge-entwurf", veroeffentlicht: "badge-veroeffentlicht", archiviert: "badge-archiviert" }[status] || "badge-inaktiv";
    const label = { entwurf: "Entwurf", veroeffentlicht: "Ver\u00f6ffentlicht", archiviert: "Archiviert" }[status] || status;
    return `<span class="badge ${cls}">${escapeHtml(label)}</span>`;
  }
  if (entity.archiviert) return '<span class="badge badge-archiviert">Archiviert</span>';
  if (entity.aktiv === false) return '<span class="badge badge-inaktiv">Inaktiv</span>';
  return '<span class="badge badge-aktiv">Aktiv</span>';
}

function adminEntityMeta(sektion, entity) {
  if (sektion === "Kategorien") {
    const parts = [];
    if (entity.farbe)                      parts.push("Farbe: " + entity.farbe);
    if (entity.sortierung !== undefined)   parts.push("Sortierung: " + entity.sortierung);
    return parts.join(" \u00b7 ");
  }
  if (sektion === "Formulare" && entity.kategorie_id) {
    return "Kategorie: " + entity.kategorie_id;
  }
  if (sektion === "Standorte" && entity.koordinaten) {
    const k = entity.koordinaten;
    return "X:" + Math.round(k.x||0) + " Y:" + Math.round(k.y||0) + " Z:" + Math.round(k.z||0);
  }
  return "";
}

function adminEntityAktionen(sektion, id, entity) {
  let html = `<button class="btn btn-secondary" data-aktion="bearbeiten">Bearbeiten</button>`;

  if (sektion === "Kategorien") {
    if (entity.aktiv !== false && !entity.archiviert) {
      html += `<button class="btn btn-secondary" data-aktion="deaktivieren">Deaktivieren</button>`;
    } else if (!entity.archiviert) {
      html += `<button class="btn btn-secondary" data-aktion="aktivieren">Aktivieren</button>`;
    }
    if (!entity.archiviert) {
      html += `<button class="btn btn-secondary" data-aktion="archivieren" style="color:#eb5757;">Archivieren</button>`;
    }
  }

  if (sektion === "Formulare") {
    const status = entity.status || "entwurf";
    if (status === "entwurf") {
      html += `<button class="btn" data-aktion="veroeffentlichen">Ver\u00f6ffentlichen</button>`;
    } else if (status === "veroeffentlicht") {
      html += `<button class="btn btn-secondary" data-aktion="archivieren" style="color:#eb5757;">Archivieren</button>`;
    } else if (status === "archiviert") {
      html += `<button class="btn btn-secondary" data-aktion="wiederherstellen">Wiederherstellen</button>`;
    }
  }

  html += `<button class="btn btn-secondary" data-aktion="loeschen" style="color:#eb5757;">L\u00f6schen</button>`;
  return html;
}

async function adminCrudAktionAusfuehren(aktion, id, entity) {
  const sektion = adminAktiveSubsektion;

  if (aktion === "bearbeiten") {
    adminCrudBearbeitenId = id;
    adminFormularAnzeigen(sektion, id, entity);
    return;
  }

  if (aktion === "loeschen") {
    const grund = prompt("L\u00f6schen von '" + id + "' in '" + sektion + "' best\u00e4tigen.\nBitte Begr\u00fcndung eingeben:");
    if (!grund || !grund.trim()) return;
    const res = await nuiAufruf("hm_bp:admin_entity_loeschen", { sektion, entity_id: id, grund: grund.trim() });
    adminCrudFeedback(res, "Eintrag gel\u00f6scht.");
    if (res && res.ok) adminCrudListeAktualisieren();
    return;
  }

  if (sektion === "Kategorien" && ["aktivieren","deaktivieren","archivieren"].includes(aktion)) {
    const grund = prompt("Aktion '" + aktion + "' f\u00fcr Kategorie '" + id + "'.\nBitte Begr\u00fcndung eingeben:");
    if (!grund || !grund.trim()) return;
    const res = await nuiAufruf("hm_bp:admin_kategorie_status", { kategorie_id: id, aktion, grund: grund.trim() });
    adminCrudFeedback(res, "Kategorie " + aktion + ".");
    if (res && res.ok) adminCrudListeAktualisieren();
    return;
  }

  if (sektion === "Formulare" && ["veroeffentlichen","archivieren","wiederherstellen"].includes(aktion)) {
    const aktionLabel = { veroeffentlichen: "ver\u00f6ffentlichen", archivieren: "archivieren", wiederherstellen: "als Entwurf wiederherstellen" }[aktion] || aktion;
    const grund = prompt("Formular '" + id + "' " + aktionLabel + "?\nBitte Begr\u00fcndung eingeben:");
    if (!grund || !grund.trim()) return;
    const res = await nuiAufruf("hm_bp:admin_formular_status", { formular_id: id, aktion, grund: grund.trim() });
    adminCrudFeedback(res, "Formular " + aktion + ".");
    if (res && res.ok) adminCrudListeAktualisieren();
    return;
  }
}

function adminCrudFeedback(res, successMsg) {
  if (adminCrudFormMeta) {
    adminCrudFormMeta.textContent = (res && res.ok)
      ? (res.nachricht || successMsg)
      : ("Fehler: " + (res?.fehler?.nachricht || "Unbekannter Fehler"));
    adminCrudFormMeta.style.color = (res && res.ok) ? "#27ae60" : "#eb5757";
  }
}

// -------------------------------------------------------
// CRUD Formular anzeigen (Anlegen / Bearbeiten)
// -------------------------------------------------------

function adminFormularAnzeigen(sektion, id, entity) {
  if (!adminCrudFormular || !adminCrudFormFelder) return;

  adminCrudFormTitel.textContent = id ? "Eintrag bearbeiten: " + id : "Neuen Eintrag anlegen";
  adminCrudFormFelder.innerHTML = "";
  adminCrudFormMeta.textContent = "";
  if (adminCrudGrund) adminCrudGrund.value = "";

  adminCrudFormFelder.appendChild(adminFormFelderErstellen(sektion, id, entity || {}));

  adminCrudFormular.style.display = "block";
  adminCrudFormular.scrollIntoView({ behavior: "smooth", block: "nearest" });
}

function adminFormularAusblenden() {
  if (adminCrudFormular) adminCrudFormular.style.display = "none";
  adminCrudBearbeitenId = null;
}

function adminFormFelderErstellen(sektion, id, entity) {
  const container = document.createElement("div");

  if (sektion === "Standorte") {
    const k = entity.koordinaten || {};
    const z = entity.zugriff || {};
    container.innerHTML = `
      <div class="admin-form-row">
        <div class="feld"><div class="label">ID (eindeutig) *</div>
          <input type="text" name="id" value="${escapeHtml(entity.id || id || "")}" placeholder="z.B. doj_frontdesk_1" ${id ? "readonly" : ""} /></div>
        <div class="feld"><div class="label">Name *</div>
          <input type="text" name="name" value="${escapeHtml(entity.name || "")}" placeholder="Anzeigename" /></div>
      </div>
      <div class="feld"><div class="label">Aktiv</div>
        <select name="aktiv"><option value="true" ${entity.aktiv !== false?"selected":""}>Ja</option><option value="false" ${entity.aktiv===false?"selected":""}>Nein</option></select></div>
      <div class="admin-form-section"><div class="admin-form-section-title">Koordinaten</div>
        <div class="admin-form-row">
          <div class="feld"><div class="label">X</div><input type="number" step="0.01" name="kx" value="${k.x ?? ""}" placeholder="0.0" /></div>
          <div class="feld"><div class="label">Y</div><input type="number" step="0.01" name="ky" value="${k.y ?? ""}" placeholder="0.0" /></div>
          <div class="feld"><div class="label">Z</div><input type="number" step="0.01" name="kz" value="${k.z ?? ""}" placeholder="0.0" /></div>
        </div>
        <div class="admin-form-row">
          <div class="feld"><div class="label">Interaktionsradius (m)</div><input type="number" step="0.1" name="interaktionsRadius" value="${entity.interaktionsRadius ?? 2.0}" /></div>
          <div class="feld"><div class="label">Sichtbarkeitsradius (m)</div><input type="number" step="0.1" name="sichtbarRadius" value="${entity.sichtbarRadius ?? 30.0}" /></div>
        </div>
      </div>
      <div class="admin-form-section"><div class="admin-form-section-title">Zugriffsregeln</div>
        <div class="admin-form-row">
          <div class="feld"><div class="label">Nur B\u00fcrger</div><select name="nurBuerger"><option value="false" ${!z.nurBuerger?"selected":""}>Nein</option><option value="true" ${z.nurBuerger?"selected":""}>Ja</option></select></div>
          <div class="feld"><div class="label">Nur Justiz</div><select name="nurJustiz"><option value="false" ${!z.nurJustiz?"selected":""}>Nein</option><option value="true" ${z.nurJustiz?"selected":""}>Ja</option></select></div>
          <div class="feld"><div class="label">Nur Admin</div><select name="nurAdmin"><option value="false" ${!z.nurAdmin?"selected":""}>Nein</option><option value="true" ${z.nurAdmin?"selected":""}>Ja</option></select></div>
        </div>
      </div>
      <div class="admin-form-section"><div class="admin-form-section-title">PED / Marker / Blip</div>
        <div class="admin-form-row">
          <div class="feld"><div class="label">PED aktiv</div><select name="pedAktiv"><option value="true" ${entity.ped?.aktiv!==false?"selected":""}>Ja</option><option value="false" ${entity.ped?.aktiv===false?"selected":""}>Nein</option></select></div>
          <div class="feld"><div class="label">PED Modell</div><input type="text" name="pedModell" value="${escapeHtml(entity.ped?.modell||"s_m_y_cop_01")}" /></div>
        </div>
        <div class="admin-form-row">
          <div class="feld"><div class="label">Marker aktiv</div><select name="markerAktiv"><option value="true" ${entity.marker?.aktiv!==false?"selected":""}>Ja</option><option value="false" ${entity.marker?.aktiv===false?"selected":""}>Nein</option></select></div>
          <div class="feld"><div class="label">Blip aktiv</div><select name="blipAktiv"><option value="true" ${entity.blip?.aktiv!==false?"selected":""}>Ja</option><option value="false" ${entity.blip?.aktiv===false?"selected":""}>Nein</option></select></div>
        </div>
      </div>`;
  } else if (sektion === "Kategorien") {
    container.innerHTML = `
      <div class="admin-form-row">
        <div class="feld"><div class="label">ID (eindeutig) *</div>
          <input type="text" name="id" value="${escapeHtml(entity.id||id||"")}" placeholder="z.B. general" ${id?"readonly":""} /></div>
        <div class="feld"><div class="label">Name *</div>
          <input type="text" name="name" value="${escapeHtml(entity.name||"")}" placeholder="Anzeigename" /></div>
      </div>
      <div class="feld"><div class="label">Beschreibung</div>
        <input type="text" name="beschreibung" value="${escapeHtml(entity.beschreibung||"")}" placeholder="Kurze Beschreibung" /></div>
      <div class="admin-form-row">
        <div class="feld"><div class="label">Farbe (Hex, z.B. #2f80ed)</div>
          <input type="text" name="farbe" value="${escapeHtml(entity.farbe||"#2f80ed")}" placeholder="#2f80ed" /></div>
        <div class="feld"><div class="label">Icon (Emoji)</div>
          <input type="text" name="icon" value="${escapeHtml(entity.icon||"")}" placeholder="\uD83D\uDCCB" /></div>
        <div class="feld"><div class="label">Sortierung</div>
          <input type="number" name="sortierung" value="${entity.sortierung??10}" /></div>
      </div>
      <div class="admin-form-row">
        <div class="feld"><div class="label">Aktiv</div>
          <select name="aktiv"><option value="true" ${entity.aktiv!==false?"selected":""}>Ja</option><option value="false" ${entity.aktiv===false?"selected":""}>Nein</option></select></div>
        <div class="feld"><div class="label">Sichtbar f\u00fcr B\u00fcrger</div>
          <select name="sichtBuerger"><option value="true" ${entity.sichtbarkeit?.buerger!==false?"selected":""}>Ja</option><option value="false" ${entity.sichtbarkeit?.buerger===false?"selected":""}>Nein</option></select></div>
      </div>
      <div class="feld"><div class="label">Webhook-URL (Discord, optional)</div>
        <input type="text" name="webhookUrl" value="${escapeHtml(entity.webhookUrl||"")}" placeholder="https://discord.com/api/webhooks/..." /></div>`;
  } else if (sektion === "Formulare") {
    const katDaten = adminPanelDaten["Kategorien"] || {};
    const katListe = katDaten.Liste || {};
    let katOptionen = '<option value="">- keine Kategorie -</option>';
    for (const [katId, kat] of Object.entries(katListe)) {
      katOptionen += `<option value="${escapeHtml(katId)}" ${entity.kategorie_id===katId?"selected":""}>${escapeHtml(kat.name||katId)}</option>`;
    }
    container.innerHTML = `
      <div class="admin-form-row">
        <div class="feld"><div class="label">ID (eindeutig) *</div>
          <input type="text" name="id" value="${escapeHtml(entity.id||id||"")}" placeholder="z.B. general_request" ${id?"readonly":""} /></div>
        <div class="feld"><div class="label">Name *</div>
          <input type="text" name="name" value="${escapeHtml(entity.name||"")}" placeholder="Anzeigename" /></div>
      </div>
      <div class="admin-form-row">
        <div class="feld"><div class="label">Kategorie</div>
          <select name="kategorie_id">${katOptionen}</select></div>
        <div class="feld"><div class="label">Status</div>
          <select name="status">
            <option value="entwurf" ${(entity.status||"entwurf")==="entwurf"?"selected":""}>Entwurf</option>
            <option value="veroeffentlicht" ${entity.status==="veroeffentlicht"?"selected":""}>Ver\u00f6ffentlicht</option>
            <option value="archiviert" ${entity.status==="archiviert"?"selected":""}>Archiviert</option>
          </select></div>
      </div>
      <div class="feld"><div class="label">Beschreibung</div>
        <input type="text" name="beschreibung" value="${escapeHtml(entity.beschreibung||"")}" placeholder="Kurze Beschreibung" /></div>
      <div class="admin-form-section"><div class="admin-form-section-title">Einschr\u00e4nkungen</div>
        <div class="admin-form-row">
          <div class="feld"><div class="label">Cooldown (Sek.)</div><input type="number" name="cooldownSekunden" value="${entity.cooldownSekunden??0}" /></div>
          <div class="feld"><div class="label">Max. offene Antr\u00e4ge</div><input type="number" name="maxOffen" value="${entity.maxOffen??0}" /></div>
        </div>
        <div class="feld"><div class="label">Duplikat-Pr\u00fcfung</div>
          <select name="duplikatPruefung"><option value="true" ${entity.duplikatPruefung!==false?"selected":""}>Ja</option><option value="false" ${entity.duplikatPruefung===false?"selected":""}>Nein</option></select></div>
      </div>
      <div class="admin-form-section"><div class="admin-form-section-title">Geb\u00fchren</div>
        <div class="admin-form-row">
          <div class="feld"><div class="label">Geb\u00fchren aktiv</div><select name="gebuehrenAktiviert"><option value="false" ${!entity.gebuehren?.aktiv?"selected":""}>Nein</option><option value="true" ${entity.gebuehren?.aktiv?"selected":""}>Ja</option></select></div>
          <div class="feld"><div class="label">Betrag (€, ganze Zahl)</div><input type="number" step="1" min="0" name="gebuehrenBetrag" value="${Math.floor(entity.gebuehren?.betrag??0)}" /></div>
        </div>
      </div>`;
  } else {
    container.innerHTML = `
      <div class="feld"><div class="label">JSON (direkte Bearbeitung)</div>
        <textarea name="json_raw" style="width:100%;min-height:200px;font-family:monospace;font-size:12px;">${escapeHtml(JSON.stringify(entity, null, 2))}</textarea></div>`;
  }

  return container;
}

// -------------------------------------------------------
// Formular-Daten sammeln und senden
// -------------------------------------------------------

async function adminCrudFormularSpeichern() {
  if (!adminCrudFormular || !adminCrudFormFelder) return;
  const sektion = adminAktiveSubsektion;
  const grund   = adminCrudGrund ? adminCrudGrund.value.trim() : "";

  if (!grund) {
    if (adminCrudFormMeta) { adminCrudFormMeta.textContent = "Begr\u00fcndung ist Pflichtfeld."; adminCrudFormMeta.style.color = "#eb5757"; }
    return;
  }

  let entityDaten = {};
  let entityId    = adminCrudBearbeitenId;
  const f         = adminCrudFormFelder;

  if (sektion === "Standorte") {
    entityId = entityId || f.querySelector("[name=id]")?.value?.trim();
    if (!entityId) { adminCrudFormMeta.textContent = "ID ist Pflichtfeld."; adminCrudFormMeta.style.color = "#eb5757"; return; }
    entityDaten = {
      id:    entityId,
      name:  f.querySelector("[name=name]")?.value?.trim() || entityId,
      aktiv: f.querySelector("[name=aktiv]")?.value !== "false",
      koordinaten: {
        x: parseFloat(f.querySelector("[name=kx]")?.value) || 0,
        y: parseFloat(f.querySelector("[name=ky]")?.value) || 0,
        z: parseFloat(f.querySelector("[name=kz]")?.value) || 0,
      },
      interaktionsRadius: parseFloat(f.querySelector("[name=interaktionsRadius]")?.value) || 2.0,
      sichtbarRadius:     parseFloat(f.querySelector("[name=sichtbarRadius]")?.value)     || 30.0,
      interaktion: {},
      zugriff: {
        nurBuerger: f.querySelector("[name=nurBuerger]")?.value === "true",
        nurJustiz:  f.querySelector("[name=nurJustiz]")?.value  === "true",
        nurAdmin:   f.querySelector("[name=nurAdmin]")?.value   === "true",
        erlaubteRollen: [], erlaubteJobs: [], erlaubteKategorien: [], erlaubteFormulare: [],
      },
      ped:    { aktiv: f.querySelector("[name=pedAktiv]")?.value !== "false",    modell: f.querySelector("[name=pedModell]")?.value?.trim() || "s_m_y_cop_01" },
      marker: { aktiv: f.querySelector("[name=markerAktiv]")?.value !== "false" },
      blip:   { aktiv: f.querySelector("[name=blipAktiv]")?.value  !== "false"  },
    };
  } else if (sektion === "Kategorien") {
    entityId = entityId || f.querySelector("[name=id]")?.value?.trim();
    if (!entityId) { adminCrudFormMeta.textContent = "ID ist Pflichtfeld."; adminCrudFormMeta.style.color = "#eb5757"; return; }
    entityDaten = {
      id:           entityId,
      name:         f.querySelector("[name=name]")?.value?.trim()        || entityId,
      beschreibung: f.querySelector("[name=beschreibung]")?.value?.trim() || "",
      farbe:        f.querySelector("[name=farbe]")?.value?.trim()        || "#2f80ed",
      icon:         f.querySelector("[name=icon]")?.value?.trim()         || "",
      sortierung:   parseInt(f.querySelector("[name=sortierung]")?.value) || 10,
      aktiv:        f.querySelector("[name=aktiv]")?.value !== "false",
      sichtbarkeit: { buerger: f.querySelector("[name=sichtBuerger]")?.value !== "false" },
    };
    const wh = f.querySelector("[name=webhookUrl]")?.value?.trim();
    if (wh) entityDaten.webhookUrl = wh;
  } else if (sektion === "Formulare") {
    entityId = entityId || f.querySelector("[name=id]")?.value?.trim();
    if (!entityId) { adminCrudFormMeta.textContent = "ID ist Pflichtfeld."; adminCrudFormMeta.style.color = "#eb5757"; return; }
    entityDaten = {
      id:              entityId,
      name:            f.querySelector("[name=name]")?.value?.trim()         || entityId,
      beschreibung:    f.querySelector("[name=beschreibung]")?.value?.trim() || "",
      status:          f.querySelector("[name=status]")?.value               || "entwurf",
      cooldownSekunden: parseInt(f.querySelector("[name=cooldownSekunden]")?.value) || 0,
      maxOffen:        parseInt(f.querySelector("[name=maxOffen]")?.value)          || 0,
      duplikatPruefung: f.querySelector("[name=duplikatPruefung]")?.value !== "false",
      gebuehren: {
        aktiv:  f.querySelector("[name=gebuehrenAktiviert]")?.value === "true",
        betrag: parsePositiveInteger(f.querySelector("[name=gebuehrenBetrag]")?.value),
      },
    };
    const katId = f.querySelector("[name=kategorie_id]")?.value;
    if (katId) entityDaten.kategorie_id = katId;
  } else {
    try {
      const rawJson = f.querySelector("[name=json_raw]")?.value || "{}";
      entityDaten = JSON.parse(rawJson);
      entityId = entityId || entityDaten.id;
    } catch(e) {
      if (adminCrudFormMeta) { adminCrudFormMeta.textContent = "JSON-Syntaxfehler: " + e.message; adminCrudFormMeta.style.color = "#eb5757"; }
      return;
    }
  }

  if (!entityId) {
    if (adminCrudFormMeta) { adminCrudFormMeta.textContent = "Entity-ID konnte nicht ermittelt werden."; adminCrudFormMeta.style.color = "#eb5757"; }
    return;
  }

  if (adminCrudFormMeta) adminCrudFormMeta.textContent = "Speichere...";
  if (btnAdminCrudSpeichern) btnAdminCrudSpeichern.disabled = true;

  const res = await nuiAufruf("hm_bp:admin_entity_speichern", { sektion, entity_id: entityId, daten: entityDaten, grund });

  if (btnAdminCrudSpeichern) btnAdminCrudSpeichern.disabled = false;
  adminCrudFeedback(res, "Eintrag erfolgreich gespeichert.");

  if (res && res.ok) {
    if (adminCrudGrund) adminCrudGrund.value = "";
    adminFormularAusblenden();
    adminCrudListeAktualisieren();
  }
}

// -------------------------------------------------------
// Modul-Toggles
// -------------------------------------------------------

function adminModulAnzeigen(daten) {
  if (!adminCrudListe) return;
  adminCrudListe.innerHTML = "";
  if (btnAdminCrudNeu) btnAdminCrudNeu.style.display = "none";

  const MODUL_BESCHREIBUNGEN = {
    AdminUI:           "Adminbereich in der NUI anzeigen",
    Anhaenge:          "Bild-Anh\u00e4nge als Links (PR8)",
    Gebuehren:         "Geb\u00fchren an Formularen (Implementierung folgt)",
    Delegation:        "Antr\u00e4ge weiterdelegieren (Implementierung folgt)",
    Entwuerfe:         "B\u00fcrger kann Entw\u00fcrfe speichern",
    Exporte:           "PDF-Export für Justiz/Admin (PR11)",
    AuditHaertung:     "Erweiterte Audit-H\u00e4rtung",
    Webhooks:          "Discord-Webhook-Benachrichtigungen",
    Benachrichtigungen: "Ingame-Benachrichtigungen",
  };

  const grid = document.createElement("div");
  grid.className = "admin-module-grid";

  for (const [modul, aktiviert] of Object.entries(daten)) {
    const card = document.createElement("div");
    card.className = "admin-module-card" + (aktiviert ? " module-aktiv" : "");

    const toggle = document.createElement("button");
    toggle.className = "admin-module-toggle" + (aktiviert ? " on" : "");
    toggle.title = aktiviert ? "Deaktivieren" : "Aktivieren";
    toggle.addEventListener("click", () => adminModulUmschalten(modul, !aktiviert));

    const info = document.createElement("div");
    info.className = "admin-module-info";
    info.innerHTML = `<div class="admin-module-name">${escapeHtml(modul)}</div>
      <div class="admin-module-status">${escapeHtml(MODUL_BESCHREIBUNGEN[modul] || "")}</div>`;

    card.appendChild(toggle);
    card.appendChild(info);
    grid.appendChild(card);
  }

  adminCrudListe.appendChild(grid);
}

async function adminModulUmschalten(modul, aktiviert) {
  const grund = prompt("Modul '" + modul + "' " + (aktiviert ? "aktivieren" : "deaktivieren") + "?\nBitte Begr\u00fcndung eingeben:");
  if (!grund || !grund.trim()) return;
  const res = await nuiAufruf("hm_bp:admin_modul_toggle", { modul, aktiviert, grund: grund.trim() });
  if (res && res.ok) {
    adminCrudListeAktualisieren();
  } else {
    alert(res?.fehler?.nachricht || "Fehler beim Umschalten.");
  }
}

// -------------------------------------------------------
// Berechtigungen (Permissions)
// -------------------------------------------------------

function adminPermissionsAnzeigen(daten) {
  if (!adminCrudListe) return;
  adminCrudListe.innerHTML = "";
  if (btnAdminCrudNeu) btnAdminCrudNeu.style.display = "none";

  const defaults = daten.Defaults || {};
  const rollen   = Object.keys(defaults);

  if (rollen.length === 0) {
    adminCrudListe.innerHTML = "<div class='muted'>Keine Berechtigungen konfiguriert. Verwende den Erweitert-Modus (JSON) zum Bearbeiten.</div>";
    return;
  }

  for (const rolle of rollen) {
    const rolleDaten = defaults[rolle] || {};
    const card = document.createElement("div");
    card.className = "admin-crud-item";
    card.style.cssText = "flex-direction:column; align-items:flex-start;";

    const rolleTitle = document.createElement("div");
    rolleTitle.className = "admin-crud-item-name";
    rolleTitle.textContent = "Rolle: " + rolle;
    card.appendChild(rolleTitle);

    const aktionen = Object.entries(rolleDaten);
    if (aktionen.length === 0) {
      const empty = document.createElement("div");
      empty.className = "muted";
      empty.textContent = "Keine Aktionen konfiguriert.";
      card.appendChild(empty);
    } else {
      const grid2 = document.createElement("div");
      grid2.style.cssText = "display:flex; flex-wrap:wrap; gap:6px; margin-top:6px;";
      for (const [aktion, erlaubt] of aktionen) {
        const badge = document.createElement("span");
        badge.className = "badge " + (erlaubt ? "badge-aktiv" : "badge-inaktiv");
        badge.textContent = aktion;
        grid2.appendChild(badge);
      }
      card.appendChild(grid2);
    }
    adminCrudListe.appendChild(card);
  }

  // -- Katalog-Abschnitt: Deutsche Bezeichnungen je Permission-Key --
  const katalog = daten.Katalog || {};
  const katalogKeys = Object.keys(katalog).sort();

  const katalogSection = document.createElement("div");
  katalogSection.style.cssText = "margin-top:18px;";

  const katalogTitel = document.createElement("div");
  katalogTitel.className = "admin-crud-item-name";
  katalogTitel.style.cssText = "font-size:1em; margin-bottom:6px;";
  katalogTitel.textContent = "Katalog – Deutsche Bezeichnungen";
  katalogSection.appendChild(katalogTitel);

  const katalogHinweis = document.createElement("div");
  katalogHinweis.className = "muted";
  katalogHinweis.style.cssText = "font-size:0.82em; margin-bottom:8px;";
  katalogHinweis.textContent = "Die deutschen Bezeichnungen werden im Tab Job-Einstellungen angezeigt. Bearbeitung über den Erweitert-Modus (JSON-Editor) unter dem Schlüssel \"Katalog\".";
  katalogSection.appendChild(katalogHinweis);

  if (katalogKeys.length === 0) {
    const empty = document.createElement("div");
    empty.className = "muted";
    empty.textContent = "Kein Katalog konfiguriert.";
    katalogSection.appendChild(empty);
  } else {
    // Gruppiere Keys nach group_de
    const gruppen = {};
    for (const key of katalogKeys) {
      const eintrag = katalog[key] || {};
      const gruppe = eintrag.group_de || "Sonstige";
      if (!gruppen[gruppe]) gruppen[gruppe] = [];
      gruppen[gruppe].push({ key, eintrag });
    }
    const gruppenNamen = Object.keys(gruppen).sort();
    for (const gruppenName of gruppenNamen) {
      const gruppeDiv = document.createElement("div");
      gruppeDiv.style.cssText = "margin-bottom:10px;";

      const gruppeHeader = document.createElement("div");
      gruppeHeader.style.cssText = "font-size:0.8em; font-weight:700; color:var(--muted,#888); text-transform:uppercase; letter-spacing:0.05em; margin-bottom:4px;";
      gruppeHeader.textContent = gruppenName;
      gruppeDiv.appendChild(gruppeHeader);

      const gruppeGrid = document.createElement("div");
      gruppeGrid.style.cssText = "display:grid; grid-template-columns:repeat(auto-fill,minmax(300px,1fr)); gap:4px;";
      for (const { key, eintrag } of gruppen[gruppenName]) {
        const row = document.createElement("div");
        row.style.cssText = "display:flex; align-items:baseline; gap:6px; padding:3px 6px; background:rgba(255,255,255,0.04); border-radius:4px; font-size:0.82em;";
        const labelSpan = document.createElement("span");
        labelSpan.style.cssText = "color:#fff; font-weight:600; flex:1;";
        labelSpan.textContent = eintrag.label_de || key.replace(/\./g, " ");
        const keySpan = document.createElement("span");
        keySpan.style.cssText = "color:var(--muted,#888); font-size:0.9em; flex-shrink:0;";
        keySpan.textContent = key;
        row.appendChild(labelSpan);
        row.appendChild(keySpan);
        gruppeGrid.appendChild(row);
      }
      gruppeDiv.appendChild(gruppeGrid);
      katalogSection.appendChild(gruppeDiv);
    }
  }
  adminCrudListe.appendChild(katalogSection);

  const hinweis = document.createElement("div");
  hinweis.className = "muted";
  hinweis.style.marginTop = "10px";
  hinweis.textContent = "F\u00fcr detaillierte Bearbeitung bitte den Erweitert-Modus (JSON-Editor) verwenden.";
  adminCrudListe.appendChild(hinweis);
}

// -------------------------------------------------------
// Status/Workflow
// -------------------------------------------------------

function adminStatusAnzeigen(daten) {
  if (!adminCrudListe) return;
  adminCrudListe.innerHTML = "";
  if (btnAdminCrudNeu) btnAdminCrudNeu.style.display = "none";

  const liste = daten.Liste || {};

  if (Object.keys(liste).length === 0) {
    adminCrudListe.innerHTML = "<div class='muted'>Keine Status konfiguriert.</div>";
    return;
  }

  for (const [id, status] of Object.entries(liste)) {
    const div = document.createElement("div");
    div.className = "admin-crud-item";
    const farbDot = status.farbe ? `<span style="width:12px;height:12px;border-radius:50%;background:${escapeHtml(status.farbe)};display:inline-block;margin-right:6px;"></span>` : "";
    div.innerHTML = `
      <div class="admin-crud-item-info">
        <div class="admin-crud-item-name">${farbDot}${escapeHtml(status.label || id)}</div>
        <div class="admin-crud-item-id">${escapeHtml(id)}</div>
        ${status.beschreibung ? `<div class="admin-crud-item-meta">${escapeHtml(status.beschreibung)}</div>` : ""}
      </div>`;
    adminCrudListe.appendChild(div);
  }

  const hinweis = document.createElement("div");
  hinweis.className = "muted";
  hinweis.style.marginTop = "10px";
  hinweis.textContent = "Status-Metadaten bitte \u00fcber den Erweitert-Modus (JSON-Editor) bearbeiten.";
  adminCrudListe.appendChild(hinweis);
}

// -------------------------------------------------------
// Webhooks
// -------------------------------------------------------

function adminWebhooksAnzeigen(daten) {
  if (!adminCrudListe) return;
  adminCrudListe.innerHTML = "";
  if (btnAdminCrudNeu) btnAdminCrudNeu.style.display = "none";

  const routing   = daten.Routing || {};
  const nachEvent = routing.NachEvent || {};

  // Test-URL Eingabe
  const testCard = document.createElement("div");
  testCard.className = "admin-webhook-card";
  testCard.innerHTML = `
    <div class="admin-form-section-title" style="margin-bottom:8px;">Webhook testen</div>
    <div style="display:flex; gap:8px; align-items:center;">
      <input type="text" id="adminWebhookTestUrl" placeholder="https://discord.com/api/webhooks/..." style="flex:1;" />
      <button id="btnAdminWebhookTest" class="btn" type="button">Testen</button>
    </div>
    <div class="muted" id="adminWebhookTestMeta" style="margin-top:6px;"></div>`;
  adminCrudListe.appendChild(testCard);

  testCard.querySelector("#btnAdminWebhookTest")?.addEventListener("click", async () => {
    const url  = testCard.querySelector("#adminWebhookTestUrl")?.value?.trim();
    const meta = testCard.querySelector("#adminWebhookTestMeta");
    if (!url) { if(meta) meta.textContent = "Bitte eine URL eingeben."; return; }
    if(meta) meta.textContent = "Sende...";
    const res = await nuiAufruf("hm_bp:admin_webhook_test", { url });
    if(meta) {
      meta.textContent  = (res && res.ok) ? (res.nachricht || "Gesendet.") : (res?.fehler?.nachricht || "Fehler.");
      meta.style.color = (res && res.ok) ? "#27ae60" : "#eb5757";
    }
  });

  const fallbackCard = document.createElement("div");
  fallbackCard.className = "admin-webhook-card";
  fallbackCard.innerHTML = `
    <div class="admin-webhook-event">Fallback-URL</div>
    <div class="admin-webhook-url">${escapeHtml(routing.Fallback || "- nicht konfiguriert -")}</div>`;
  adminCrudListe.appendChild(fallbackCard);

  const events = Object.entries(nachEvent);
  if (events.length === 0) {
    const empty = document.createElement("div");
    empty.className = "muted";
    empty.style.marginTop = "8px";
    empty.textContent = "Keine Event-Webhooks konfiguriert. Verwende den Erweitert-Modus (JSON) zum Hinzuf\u00fcgen.";
    adminCrudListe.appendChild(empty);
  } else {
    for (const [event, url] of events) {
      const card = document.createElement("div");
      card.className = "admin-webhook-card";
      card.innerHTML = `<div class="admin-webhook-event">${escapeHtml(event)}</div>
        <div class="admin-webhook-url">${escapeHtml(url)}</div>`;
      adminCrudListe.appendChild(card);
    }
  }

  const hinweis = document.createElement("div");
  hinweis.className = "muted";
  hinweis.style.marginTop = "10px";
  hinweis.textContent = "Webhook-URLs bitte \u00fcber den Erweitert-Modus (JSON-Editor) bearbeiten.";
  adminCrudListe.appendChild(hinweis);
}

// -------------------------------------------------------
// Erweitert (JSON-Modus)
// -------------------------------------------------------

async function adminSektionLaden(modus) {
  if (!adminCrudErweitert) return;
  const sektion = adminAktiveSubsektion;
  if (!adminAktionMeta) return;
  adminAktionMeta.textContent = "Lade Sektion...";
  const res = await nuiAufruf("hm_bp:admin_sektion_laden", { sektion, modus: modus || "effektiv" });
  if (!res || !res.ok) {
    adminAktionMeta.textContent = res?.fehler?.nachricht || "Laden fehlgeschlagen.";
    return;
  }
  try {
    if (adminJsonEditor) adminJsonEditor.value = JSON.stringify(res.daten, null, 2);
    adminAktionMeta.textContent = "Sektion '" + sektion + "' geladen (Modus: " + (modus || "effektiv") + ").";
  } catch(e) {
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
  try { daten = JSON.parse(raw); } catch(e) {
    if (adminAktionMeta) adminAktionMeta.textContent = "JSON-Syntaxfehler: " + e.message;
    return;
  }
  if (adminAktionMeta) adminAktionMeta.textContent = "Validierung l\u00e4uft...";
  const res = await nuiAufruf("hm_bp:admin_sektion_validieren", { sektion, daten });
  if (!res || !res.ok) {
    if (adminAktionMeta) adminAktionMeta.textContent = "Validierungsfehler: " + (res?.fehler?.nachricht || "Unbekannter Fehler");
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
  try { daten = JSON.parse(raw); } catch(e) {
    if (adminAktionMeta) adminAktionMeta.textContent = "JSON-Syntaxfehler: " + e.message;
    return;
  }
  if (adminAktionMeta) adminAktionMeta.textContent = "Speichere...";
  if (btnAdminSpeichern) btnAdminSpeichern.disabled = true;
  const res = await nuiAufruf("hm_bp:admin_sektion_speichern", { sektion, daten, grund });
  if (btnAdminSpeichern) btnAdminSpeichern.disabled = false;
  if (!res || !res.ok) {
    if (adminAktionMeta) adminAktionMeta.textContent = "Fehler: " + (res?.fehler?.nachricht || "Speichern fehlgeschlagen.");
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
  if (!confirm("Override f\u00fcr Sektion '" + sektion + "' zur\u00fccksetzen? Die Basis-Config wird wieder aktiv.")) return;
  if (adminAktionMeta) adminAktionMeta.textContent = "Setze zur\u00fcck...";
  const res = await nuiAufruf("hm_bp:admin_sektion_zuruecksetzen", { sektion, grund });
  if (!res || !res.ok) {
    if (adminAktionMeta) adminAktionMeta.textContent = "Fehler: " + (res?.fehler?.nachricht || "Zur\u00fccksetzen fehlgeschlagen.");
    return;
  }
  if (adminAktionMeta) adminAktionMeta.textContent = res.nachricht || "Override zur\u00fcckgesetzt.";
  if (adminGrund) adminGrund.value = "";
  if (adminJsonEditor) adminJsonEditor.value = "";
}

// -------------------------------------------------------
// Audit-Log (PR12): Filter + Pagination
// -------------------------------------------------------

function auditFilterHolen() {
  return {
    von:              (auditFilterVon?.value       || "").trim(),
    bis:              (auditFilterBis?.value       || "").trim(),
    actor_name:       (auditFilterActorName?.value || "").trim(),
    aktion:           (auditFilterAktion?.value    || "").trim(),
    target_public_id: (auditFilterPublicId?.value  || "").trim(),
    request_id:       (auditFilterRequestId?.value || "").trim(),
  };
}

async function auditListeLaden(seite) {
  if (!adminAuditListe) return;
  if (seite !== undefined) auditAktuelleSeite = seite;

  adminAuditListe.innerHTML = "<div class='muted'>Lade\u2026</div>";
  if (auditSeitenInfo) auditSeitenInfo.textContent = "Lade\u2026";

  const proSeiteWert = parseInt(auditProSeite?.value || "50");
  const filter = auditFilterHolen();

  const res = await nuiAufruf("hm_bp:audit_liste_laden", {
    filter,
    seite:     auditAktuelleSeite,
    pro_seite: proSeiteWert,
  });

  adminAuditListe.innerHTML = "";

  if (!res || !res.ok) {
    adminAuditListe.innerHTML = "<div class='muted'>" + escapeHtml(res?.fehler?.nachricht || "Audit-Log konnte nicht geladen werden.") + "</div>";
    if (auditSeitenInfo) auditSeitenInfo.textContent = "\u2013";
    return;
  }

  const eintraege = res.eintraege || [];
  auditGesamt = res.gesamt || 0;
  const gesamtSeiten = Math.max(1, Math.ceil(auditGesamt / proSeiteWert));

  if (auditSeitenInfo) {
    auditSeitenInfo.textContent = `Seite ${auditAktuelleSeite} / ${gesamtSeiten} (${auditGesamt} Eintr\u00e4ge)`;
  }
  if (btnAuditVorige)   btnAuditVorige.disabled   = auditAktuelleSeite <= 1;
  if (btnAuditNaechste) btnAuditNaechste.disabled = auditAktuelleSeite >= gesamtSeiten;

  if (eintraege.length === 0) {
    adminAuditListe.innerHTML = "<div class='muted'>Keine Audit-Eintr\u00e4ge f\u00fcr diese Filter vorhanden.</div>";
    return;
  }

  const istAdmin = res.ist_admin === true;

  for (const e of eintraege) {
    const div = document.createElement("div");
    div.className = "admin-audit-entry";

    const actorLine = escapeHtml(e.actor_display_name || e.actor_name || "?")
      + (e.actor_source ? ` <span class="muted">[${escapeHtml(e.actor_source)}]</span>` : "")
      + (istAdmin && e.actor_identifier ? ` <span class="muted audit-identifier">(${escapeHtml(e.actor_identifier)})</span>` : "");

    div.innerHTML = `
      <div class="admin-audit-header">
        <span class="admin-audit-ts">${escapeHtml(String(e.created_at || "?"))}</span>
        <span class="admin-audit-action">${escapeHtml(e.action || "?")}</span>
        ${e.target_public_id ? `<span class="admin-audit-section">AZ: ${escapeHtml(e.target_public_id)}</span>` : ""}
      </div>
      <div class="admin-audit-actor">${actorLine}</div>
      ${e.reason ? `<div class="admin-audit-grund">Begr\u00fcndung: ${escapeHtml(e.reason)}</div>` : ""}
      <div class="admin-audit-id muted">
        Request-ID: <strong>${escapeHtml(e.request_id || "?")}</strong>
        ${e.target_type ? ` &middot; Ziel: ${escapeHtml(e.target_type)}${e.target_id ? "/" + escapeHtml(e.target_id) : ""}` : ""}
      </div>`;
    adminAuditListe.appendChild(div);
  }
}

// Legacy-Wrapper (für alte Referenz in Event-Listenern)
async function adminAuditLogLaden() {
  auditAktuelleSeite = 1;
  await auditListeLaden(1);
}

// -------------------------------------------------------
// PR15: JobSettings – Job-Grade-Berechtigungen verwalten
// -------------------------------------------------------

async function adminJobSettingsLaden() {
  if (jobSettingsMeta) jobSettingsMeta.textContent = "Lade\u2026";
  const res = await nuiAufruf("hm_bp:admin_job_settings_laden", {});
  if (!res || !res.ok) {
    if (jobSettingsMeta) {
      jobSettingsMeta.textContent = res?.fehler?.nachricht || "Laden fehlgeschlagen.";
      jobSettingsMeta.style.color = "#eb5757";
    }
    return;
  }
  if (jobSettingsMeta) { jobSettingsMeta.textContent = ""; jobSettingsMeta.style.color = ""; }

  jobSettingsDaten          = res.daten          || {};
  jobSettingsBasis          = res.basis          || {};
  jobSettingsAktionen       = res.aktionen       || [];
  jobSettingsRollenDefaults = res.rollenDefaults || {};
  jobSettingsPermKatalog    = res.permKatalog    || {};
  jobSettingsAktivJob       = null;
  jobSettingsAktivGrade     = null;

  jobSettingsJobListeAnzeigen();
  if (jobSettingsGradeListe) jobSettingsGradeListe.innerHTML = "<div class='muted' style='padding:8px;'>Bitte einen Job ausw\u00e4hlen.</div>";
  if (jobSettingsPermGrid)   jobSettingsPermGrid.innerHTML   = "<div class='muted' style='padding:8px;'>Bitte einen Rang ausw\u00e4hlen.</div>";
  if (jobSettingsPermTitel)  jobSettingsPermTitel.textContent = "Berechtigungen";
}

function jobSettingsJobListeAnzeigen() {
  if (!jobSettingsJobListe) return;
  jobSettingsJobListe.innerHTML = "";
  const jobs = (jobSettingsDaten.Jobs) || {};
  const jobKeys = Object.keys(jobs).sort();
  if (jobKeys.length === 0) {
    jobSettingsJobListe.innerHTML = "<div class='muted' style='padding:8px;'>Keine Jobs konfiguriert.</div>";
    return;
  }
  for (const key of jobKeys) {
    const jobDef = jobs[key] || {};
    const btn = document.createElement("button");
    btn.className = "admin-crud-item";
    btn.style.cssText = "cursor:pointer; width:100%; text-align:left; background:none; border:none; padding:6px 8px;";
    btn.setAttribute("aria-label", `Job: ${jobDef.anzeigeName || key} (${key})`);
    btn.innerHTML = `<strong>${escapeHtml(jobDef.anzeigeName || key)}</strong><br><span class="muted" style="font-size:0.82em;">${escapeHtml(key)}</span>`;
    btn.addEventListener("click", () => jobSettingsJobAuswaehlen(key));
    jobSettingsJobListe.appendChild(btn);
  }
}

function jobSettingsJobAuswaehlen(jobName) {
  jobSettingsAktivJob   = jobName;
  jobSettingsAktivGrade = null;

  // Highlight
  jobSettingsJobListe.querySelectorAll(".admin-crud-item").forEach(el => {
    el.style.background = el.querySelector("strong")?.textContent === ((jobSettingsDaten.Jobs || {})[jobName]?.anzeigeName || jobName)
      ? "rgba(255,255,255,0.08)"
      : "";
  });

  if (jobSettingsPermGrid)  jobSettingsPermGrid.innerHTML  = "<div class='muted' style='padding:8px;'>Bitte einen Rang ausw\u00e4hlen.</div>";
  if (jobSettingsPermTitel) jobSettingsPermTitel.textContent = "Berechtigungen";
  jobSettingsGradeListeAnzeigen(jobName);
}

function jobSettingsGradeListeAnzeigen(jobName) {
  if (!jobSettingsGradeListe) return;
  jobSettingsGradeListe.innerHTML = "";
  const jobDef = ((jobSettingsDaten.Jobs) || {})[jobName] || {};
  const grades = Array.isArray(jobDef.grades) ? jobDef.grades : [];
  if (grades.length === 0) {
    jobSettingsGradeListe.innerHTML = "<div class='muted' style='padding:8px;'>Keine R\u00e4nge definiert.</div>";
    return;
  }
  const sortedGrades = [...grades].sort((a, b) => (a.grade ?? 0) - (b.grade ?? 0));
  for (const g of sortedGrades) {
    const btn = document.createElement("button");
    btn.className = "admin-crud-item";
    btn.style.cssText = "cursor:pointer; width:100%; text-align:left; background:none; border:none; padding:6px 8px;";
    btn.dataset.grade = String(g.grade);
    btn.setAttribute("aria-label", `Rang ${g.grade}${g.name ? ", " + g.name : ""}`);
    btn.innerHTML = `<strong>Rang ${escapeHtml(String(g.grade))}</strong><br><span class="muted" style="font-size:0.82em;">${escapeHtml(g.name || "")}</span>`;
    btn.addEventListener("click", () => jobSettingsGradeAuswaehlen(jobName, g.grade));
    jobSettingsGradeListe.appendChild(btn);
  }
}

function jobSettingsGradeAuswaehlen(jobName, gradeNum) {
  jobSettingsAktivGrade = gradeNum;

  // Highlight
  jobSettingsGradeListe.querySelectorAll(".admin-crud-item").forEach(el => {
    el.style.background = el.dataset.grade === String(gradeNum) ? "rgba(255,255,255,0.08)" : "";
  });

  jobSettingsPermAnzeigen(jobName, gradeNum);
}

// Gibt den deutschen Anzeigenamen für einen Permission-Key zurück.
// Nutzt den Katalog (Admin-konfigurierbar) oder fällt auf den Key mit
// Punkten als Leerzeichen zurück.
function permLabelDe(aktion) {
  const eintrag = jobSettingsPermKatalog[aktion];
  if (eintrag && eintrag.label_de) return eintrag.label_de;
  return String(aktion).replace(/\./g, " ");
}

function jobSettingsPermAnzeigen(jobName, gradeNum) {
  if (!jobSettingsPermGrid) return;
  jobSettingsPermGrid.innerHTML = "";

  const jobDef       = ((jobSettingsDaten.Jobs) || {})[jobName] || {};
  const gradeName    = (Array.isArray(jobDef.grades) ? jobDef.grades.find(g => g.grade === gradeNum) : null)?.name || "";
  const defaultRolle = jobDef.globalDefaultRolle || jobName;
  const rolleDefault = (jobSettingsRollenDefaults[defaultRolle]) || { allow: [], deny: [] };
  const gradPerms    = (jobDef.gradPermissions || {})[gradeNum] || { allow: [], deny: [] };

  if (jobSettingsPermTitel) {
    jobSettingsPermTitel.textContent = `Berechtigungen – ${jobName} Rang ${gradeNum}${gradeName ? " (" + gradeName + ")" : ""}`;
  }

  const globalAllow = rolleDefault.allow || [];
  const globalDeny  = rolleDefault.deny  || [];
  const gradeAllow  = Array.isArray(gradPerms.allow) ? [...gradPerms.allow] : [];
  const gradeDeny   = Array.isArray(gradPerms.deny)  ? [...gradPerms.deny]  : [];

  const isGlobalAllowed = (action) => {
    if (globalDeny.includes(action)) return false;
    if (globalAllow.includes("*") || globalAllow.includes(action)) return true;
    return false;
  };

  // Sortiere Aktionen nach Kategorie (Prefix vor dem Punkt)
  const aktionen = [...jobSettingsAktionen];

  // Legende
  const legende = document.createElement("div");
  legende.style.cssText = "margin-bottom:8px; font-size:0.82em; color:var(--muted,#888);";
  legende.innerHTML = "Klicke eine Aktion um den Override-Status zu ändern: <strong style='color:#27ae60;'>&#10003;</strong> erlaubt &nbsp; <strong style='color:#eb5757;'>&#10007;</strong> verweigert &nbsp; <span style='opacity:0.6;'>&#9679;</span> geerbt";
  jobSettingsPermGrid.appendChild(legende);

  // Grid der Aktionen
  const grid = document.createElement("div");
  grid.style.cssText = "display:grid; grid-template-columns: repeat(auto-fill, minmax(280px,1fr)); gap:4px;";
  jobSettingsPermGrid.appendChild(grid);

  for (const aktion of aktionen) {
    const isOverrideAllow = gradeAllow.includes("*") || gradeAllow.includes(aktion);
    const isOverrideDeny  = gradeDeny.includes(aktion);
    const isInherited     = !isOverrideAllow && !isOverrideDeny;

    // Status: "erlaubt" | "verweigert" | "geerbt-erlaubt" | "geerbt-verweigert"
    let statusKlasse, statusIcon;
    if (isOverrideAllow) {
      statusKlasse = "js-allow";
      statusIcon   = "\u2713";
    } else if (isOverrideDeny) {
      statusKlasse = "js-deny";
      statusIcon   = "\u2717";
    } else if (isGlobalAllowed(aktion)) {
      statusKlasse = "js-inherited-allow";
      statusIcon   = "\u25cf";
    } else {
      statusKlasse = "js-inherited-deny";
      statusIcon   = "\u25cb";
    }

    const btn = document.createElement("button");
    btn.type = "button";
    btn.style.cssText = "display:flex; align-items:center; gap:6px; padding:5px 8px; border-radius:4px; border:1px solid transparent; cursor:pointer; font-size:0.82em; text-align:left; color:#fff;";
    btn.dataset.aktion  = aktion;
    btn.dataset.status  = statusKlasse;
    btn.title = aktion;

    if (statusKlasse === "js-allow")           { btn.style.background = "rgba(39,174,96,0.18)";  btn.style.borderColor = "#27ae60"; }
    else if (statusKlasse === "js-deny")       { btn.style.background = "rgba(235,87,87,0.18)";  btn.style.borderColor = "#eb5757"; }
    else if (statusKlasse === "js-inherited-allow") { btn.style.background = "rgba(255,255,255,0.04)"; btn.style.opacity = "0.75"; }
    else                                       { btn.style.background = "transparent";           btn.style.opacity = "0.5"; }

    btn.innerHTML = `<span style="font-weight:700; min-width:16px; text-align:center;">${statusIcon}</span> <span>${escapeHtml(permLabelDe(aktion))}</span>`;

    btn.addEventListener("click", () => {
      // Zustand zyklisch wechseln: inherit → override-allow → override-deny → inherit
      const curr = btn.dataset.status;
      let next;
      if (curr === "js-inherited-allow" || curr === "js-inherited-deny") {
        next = "js-allow";
      } else if (curr === "js-allow") {
        next = "js-deny";
      } else {
        next = isGlobalAllowed(aktion) ? "js-inherited-allow" : "js-inherited-deny";
      }

      // gradeAllow / gradeDeny in jobSettingsDaten aktualisieren
      const jDef = (jobSettingsDaten.Jobs || {})[jobName];
      if (!jDef) return;
      if (!jDef.gradPermissions) jDef.gradPermissions = {};
      if (!jDef.gradPermissions[gradeNum]) jDef.gradPermissions[gradeNum] = { allow: [], deny: [] };
      const gp = jDef.gradPermissions[gradeNum];
      if (!Array.isArray(gp.allow)) gp.allow = [];
      if (!Array.isArray(gp.deny))  gp.deny  = [];

      // Entfernen aus alten Listen
      gp.allow = gp.allow.filter(a => a !== aktion);
      gp.deny  = gp.deny.filter(a  => a !== aktion);

      if (next === "js-allow") {
        gp.allow.push(aktion);
      } else if (next === "js-deny") {
        gp.deny.push(aktion);
      }

      // Button-Darstellung aktualisieren
      btn.dataset.status = next;
      if (next === "js-allow") {
        btn.style.background  = "rgba(39,174,96,0.18)"; btn.style.borderColor = "#27ae60"; btn.style.opacity = "1";
        btn.querySelector("span").textContent = "\u2713";
      } else if (next === "js-deny") {
        btn.style.background  = "rgba(235,87,87,0.18)"; btn.style.borderColor = "#eb5757"; btn.style.opacity = "1";
        btn.querySelector("span").textContent = "\u2717";
      } else if (next === "js-inherited-allow") {
        btn.style.background = "rgba(255,255,255,0.04)"; btn.style.borderColor = "transparent"; btn.style.opacity = "0.75";
        btn.querySelector("span").textContent = "\u25cf";
      } else {
        btn.style.background = "transparent"; btn.style.borderColor = "transparent"; btn.style.opacity = "0.5";
        btn.querySelector("span").textContent = "\u25cb";
      }
    });

    grid.appendChild(btn);
  }
}

async function adminJobSettingsSpeichern() {
  const grund = jobSettingsGrund ? jobSettingsGrund.value.trim() : "";
  if (!grund) {
    if (jobSettingsMeta) { jobSettingsMeta.textContent = "Bitte einen Grund eingeben (Pflichtfeld)."; jobSettingsMeta.style.color = "#eb5757"; }
    return;
  }
  if (jobSettingsMeta) { jobSettingsMeta.textContent = "Speichere\u2026"; jobSettingsMeta.style.color = ""; }
  if (btnJobSettingsSpeichern) btnJobSettingsSpeichern.disabled = true;

  const res = await nuiAufruf("hm_bp:admin_job_settings_speichern", { daten: jobSettingsDaten, grund });

  if (btnJobSettingsSpeichern) btnJobSettingsSpeichern.disabled = false;
  if (!res || !res.ok) {
    if (jobSettingsMeta) { jobSettingsMeta.textContent = res?.fehler?.nachricht || "Speichern fehlgeschlagen."; jobSettingsMeta.style.color = "#eb5757"; }
    return;
  }
  if (jobSettingsMeta) { jobSettingsMeta.textContent = res.nachricht || "Gespeichert."; jobSettingsMeta.style.color = "#27ae60"; }
  if (jobSettingsGrund) jobSettingsGrund.value = "";
}

async function adminJobSettingsZuruecksetzen() {
  const grund = jobSettingsGrund ? jobSettingsGrund.value.trim() : "";
  if (!grund) {
    if (jobSettingsMeta) { jobSettingsMeta.textContent = "Bitte einen Grund eingeben (Pflichtfeld)."; jobSettingsMeta.style.color = "#eb5757"; }
    return;
  }
  if (!confirm("JobSettings auf Basis-Defaults zur\u00fccksetzen? Alle gespeicherten \u00dcberschreibungen gehen verloren.")) return;
  if (jobSettingsMeta) { jobSettingsMeta.textContent = "Setze zur\u00fcck\u2026"; jobSettingsMeta.style.color = ""; }

  const res = await nuiAufruf("hm_bp:admin_job_settings_zuruecksetzen", { grund });
  if (!res || !res.ok) {
    if (jobSettingsMeta) { jobSettingsMeta.textContent = res?.fehler?.nachricht || "Zur\u00fccksetzen fehlgeschlagen."; jobSettingsMeta.style.color = "#eb5757"; }
    return;
  }
  if (jobSettingsMeta) { jobSettingsMeta.textContent = res.nachricht || "Zur\u00fcckgesetzt."; jobSettingsMeta.style.color = "#27ae60"; }
  if (jobSettingsGrund) jobSettingsGrund.value = "";
  await adminJobSettingsLaden();
}

function jobSettingsGradeHinzufuegen() {
  if (!jobSettingsAktivJob) {
    if (jobSettingsMeta) { jobSettingsMeta.textContent = "Bitte zuerst einen Job ausw\u00e4hlen."; jobSettingsMeta.style.color = "#eb5757"; }
    return;
  }
  const gradeNum  = parseInt(jobSettingsNeuerGrade ? jobSettingsNeuerGrade.value : "");
  const gradeName = jobSettingsNeuerGradeName ? jobSettingsNeuerGradeName.value.trim() : "";
  if (isNaN(gradeNum) || gradeNum < 0) {
    if (jobSettingsMeta) { jobSettingsMeta.textContent = "Bitte eine g\u00fcltige Rang-Nummer eingeben."; jobSettingsMeta.style.color = "#eb5757"; }
    return;
  }
  const jobDef = ((jobSettingsDaten.Jobs) || {})[jobSettingsAktivJob];
  if (!jobDef) {
    if (jobSettingsMeta) { jobSettingsMeta.textContent = "Job nicht gefunden."; jobSettingsMeta.style.color = "#eb5757"; }
    return;
  }
  if (!Array.isArray(jobDef.grades)) jobDef.grades = [];
  if (jobDef.grades.find(g => g.grade === gradeNum)) {
    if (jobSettingsMeta) { jobSettingsMeta.textContent = `Rang ${gradeNum} existiert bereits.`; jobSettingsMeta.style.color = "#eb5757"; }
    return;
  }
  jobDef.grades.push({ grade: gradeNum, name: gradeName || `Rang ${gradeNum}` });
  if (jobSettingsNeuerGrade)     jobSettingsNeuerGrade.value     = "";
  if (jobSettingsNeuerGradeName) jobSettingsNeuerGradeName.value = "";
  if (jobSettingsMeta) { jobSettingsMeta.textContent = `Rang ${gradeNum} hinzugef\u00fcgt (noch nicht gespeichert).`; jobSettingsMeta.style.color = "#f39c12"; }
  jobSettingsGradeListeAnzeigen(jobSettingsAktivJob);
}

function jobSettingsGradeEntfernen() {
  if (!jobSettingsAktivJob || jobSettingsAktivGrade === null) {
    if (jobSettingsMeta) { jobSettingsMeta.textContent = "Bitte zuerst einen Rang ausw\u00e4hlen."; jobSettingsMeta.style.color = "#eb5757"; }
    return;
  }
  if (!confirm(`Rang ${jobSettingsAktivGrade} aus Job "${jobSettingsAktivJob}" entfernen?`)) return;
  const jobDef = ((jobSettingsDaten.Jobs) || {})[jobSettingsAktivJob];
  if (!jobDef) return;
  if (Array.isArray(jobDef.grades)) {
    jobDef.grades = jobDef.grades.filter(g => g.grade !== jobSettingsAktivGrade);
  }
  if (jobDef.gradPermissions) {
    delete jobDef.gradPermissions[jobSettingsAktivGrade];
  }
  if (jobSettingsMeta) { jobSettingsMeta.textContent = `Rang ${jobSettingsAktivGrade} entfernt (noch nicht gespeichert).`; jobSettingsMeta.style.color = "#f39c12"; }
  jobSettingsAktivGrade = null;
  if (jobSettingsPermGrid)  jobSettingsPermGrid.innerHTML  = "<div class='muted' style='padding:8px;'>Bitte einen Rang ausw\u00e4hlen.</div>";
  if (jobSettingsPermTitel) jobSettingsPermTitel.textContent = "Berechtigungen";
  jobSettingsGradeListeAnzeigen(jobSettingsAktivJob);
}

// -------------------------------------------------------
// Event-Listener binden
// -------------------------------------------------------

document.querySelectorAll(".admin-subtab").forEach(btn => {
  btn.addEventListener("click", () => adminSubtabSetzen(btn.dataset.subtab));
});

if (btnAdminModeGefuehrt)  btnAdminModeGefuehrt.addEventListener("click",   () => adminModusSetzen("gefuehrt"));
if (btnAdminModeErweitert) btnAdminModeErweitert.addEventListener("click",  () => adminModusSetzen("erweitert"));

if (btnAdminLaden)         btnAdminLaden.addEventListener("click",        () => adminSektionLaden("effektiv"));
if (btnAdminBasisLaden)    btnAdminBasisLaden.addEventListener("click",   () => adminSektionLaden("basis"));
if (btnAdminOverrideLaden) btnAdminOverrideLaden.addEventListener("click",() => adminSektionLaden("override"));
if (btnAdminValidieren)    btnAdminValidieren.addEventListener("click",   () => adminSektionValidieren());
if (btnAdminSpeichern)     btnAdminSpeichern.addEventListener("click",    () => adminSektionSpeichern());
if (btnAdminZuruecksetzen) btnAdminZuruecksetzen.addEventListener("click",() => adminSektionZuruecksetzen());

// PR12: Audit-Filter + Pagination
if (btnAuditSuchen)    btnAuditSuchen.addEventListener("click",    () => auditListeLaden(1));
if (btnAuditZurueck)   btnAuditZurueck.addEventListener("click",   () => {
  if (auditFilterVon)       auditFilterVon.value       = "";
  if (auditFilterBis)       auditFilterBis.value       = "";
  if (auditFilterActorName) auditFilterActorName.value = "";
  if (auditFilterAktion)    auditFilterAktion.value    = "";
  if (auditFilterPublicId)  auditFilterPublicId.value  = "";
  if (auditFilterRequestId) auditFilterRequestId.value = "";
  auditListeLaden(1);
});
if (btnAuditVorige)    btnAuditVorige.addEventListener("click",    () => {
  if (auditAktuelleSeite > 1) auditListeLaden(auditAktuelleSeite - 1);
});
if (btnAuditNaechste)  btnAuditNaechste.addEventListener("click",  () => {
  const pp = parseInt(auditProSeite?.value || "50");
  if (auditAktuelleSeite < Math.ceil(auditGesamt / pp)) auditListeLaden(auditAktuelleSeite + 1);
});
if (auditProSeite) auditProSeite.addEventListener("change", () => auditListeLaden(1));

if (btnAdminCrudNeu)            btnAdminCrudNeu.addEventListener("click",            () => { adminCrudBearbeitenId = null; adminFormularAnzeigen(adminAktiveSubsektion, null, {}); });
if (btnAdminCrudAktualisieren)  btnAdminCrudAktualisieren.addEventListener("click",  () => adminCrudListeAktualisieren());
if (btnAdminCrudSpeichern)      btnAdminCrudSpeichern.addEventListener("click",      () => adminCrudFormularSpeichern());
if (btnAdminCrudAbbrechen)      btnAdminCrudAbbrechen.addEventListener("click",      () => adminFormularAusblenden());

// PR15: JobSettings
if (btnJobSettingsAktualisieren) btnJobSettingsAktualisieren.addEventListener("click", () => adminJobSettingsLaden());
if (btnJobSettingsSpeichern)     btnJobSettingsSpeichern.addEventListener("click",     () => adminJobSettingsSpeichern());
if (btnJobSettingsZuruecksetzen) btnJobSettingsZuruecksetzen.addEventListener("click", () => adminJobSettingsZuruecksetzen());
if (btnJobSettingsGradeHinzu)    btnJobSettingsGradeHinzu.addEventListener("click",    () => jobSettingsGradeHinzufuegen());
if (btnJobSettingsGradeEntf)     btnJobSettingsGradeEntf.addEventListener("click",     () => jobSettingsGradeEntfernen());

if (tabAdmin) {
  tabAdmin.addEventListener("click", () => {
    tabSetzen("admin");
    adminPanelLaden();
  });
}

// ==========================
// PR3: Delegation / Stellvertretung
// ==========================

// Hilfs-Funktion: Spieler-Suchergebnisse als klickbare Liste rendern
function delegationSpielerListeRendern(container, ergebnisse, onAuswahl) {
  if (!container) return;
  container.innerHTML = "";
  if (!ergebnisse || ergebnisse.length === 0) {
    container.innerHTML = "<div class='muted'>Keine Treffer.</div>";
    return;
  }
  // Prüfe auf Doppelname
  const nameCount = {};
  ergebnisse.forEach(e => {
    nameCount[e.name] = (nameCount[e.name] || 0) + 1;
  });
  ergebnisse.forEach(sp => {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "btn btn-secondary";
    btn.style.cssText = "display:block; margin-bottom:4px; text-align:left; width:100%;";
    // Bei Doppelname: Server-ID zur Unterscheidung anzeigen (kein Identifier-Leak)
    if (nameCount[sp.name] > 1) {
      btn.textContent = `${sp.name} (Spieler #${sp.source})`;
    } else {
      btn.textContent = sp.name;
    }
    btn.addEventListener("click", () => onAuswahl(sp));
    container.appendChild(btn);
  });
}

// Delegation-Bereich: Typ-Auswahl steuert Zielbereich
if (delegationTyp) {
  delegationTyp.addEventListener("change", () => {
    const gewaehlt = delegationTyp.value;
    if (delegationZielBereich) {
      delegationZielBereich.style.display = gewaehlt ? "" : "none";
    }
    // Auswahl zurücksetzen
    delegationAusgewaehlterSpieler = null;
    if (delegationAuswahlAnzeige) delegationAuswahlAnzeige.textContent = "";
    if (delegationSuchergebnisse) delegationSuchergebnisse.innerHTML = "";
    if (delegationSuchMeta) delegationSuchMeta.textContent = "";
  });
}

// Delegation-Suche starten
if (btnDelegationSuchen) {
  btnDelegationSuchen.addEventListener("click", async () => {
    if (!delegationSuchname) return;
    const name = delegationSuchname.value.trim();
    if (name.length < 2) {
      if (delegationSuchMeta) delegationSuchMeta.textContent = "Bitte mindestens 2 Zeichen eingeben.";
      return;
    }
    if (delegationSuchMeta) delegationSuchMeta.textContent = "Suche läuft…";
    if (delegationSuchergebnisse) delegationSuchergebnisse.innerHTML = "";
    await nuiAufruf("hm_bp:delegation_online_spieler_suchen", { name });
  });
}

// Hilfsantrag-Suche starten (Justiz/Admin)
if (btnHilfsantragSuchen) {
  btnHilfsantragSuchen.addEventListener("click", async () => {
    if (!hilfsantragSuchname) return;
    const name = hilfsantragSuchname.value.trim();
    if (name.length < 2) {
      if (hilfsantragSuchMeta) hilfsantragSuchMeta.textContent = "Bitte mindestens 2 Zeichen eingeben.";
      return;
    }
    if (hilfsantragSuchMeta) hilfsantragSuchMeta.textContent = "Suche läuft…";
    if (hilfsantragSuchergebnisse) hilfsantragSuchergebnisse.innerHTML = "";
    // Merke Kontext: Hilfsantrag
    window._delegationSuchKontext = "hilfsantrag";
    await nuiAufruf("hm_bp:delegation_online_spieler_suchen", { name });
  });
}

// Vollmacht-Suche: Auftraggeber
const btnVollmachtAuftraggeberSuchen = document.getElementById("btnVollmachtAuftraggeberSuchen");
const vollmachtAuftraggeberSuche     = document.getElementById("vollmachtAuftraggeberSuche");
const vollmachtAuftraggeberErgebnisse= document.getElementById("vollmachtAuftraggeberErgebnisse");
const vollmachtAuftraggeberAuswahl   = document.getElementById("vollmachtAuftraggeberAuswahl");

if (btnVollmachtAuftraggeberSuchen) {
  btnVollmachtAuftraggeberSuchen.addEventListener("click", async () => {
    const name = vollmachtAuftraggeberSuche?.value?.trim() || "";
    if (name.length < 2) {
      if (vollmachtAuftraggeberErgebnisse) vollmachtAuftraggeberErgebnisse.innerHTML = "<div class='muted'>Bitte mindestens 2 Zeichen eingeben.</div>";
      return;
    }
    if (vollmachtAuftraggeberErgebnisse) vollmachtAuftraggeberErgebnisse.innerHTML = "<div class='muted'>Suche läuft…</div>";
    window._delegationSuchKontext = "vollmacht_auftraggeber";
    await nuiAufruf("hm_bp:delegation_online_spieler_suchen", { name });
  });
}

// Vollmacht-Suche: Bevollmächtigter
const btnVollmachtBevollmaechtigterSuchen  = document.getElementById("btnVollmachtBevollmaechtigterSuchen");
const vollmachtBevollmaechtigterSuche      = document.getElementById("vollmachtBevollmaechtigterSuche");
const vollmachtBevollmaechtigterErgebnisse = document.getElementById("vollmachtBevollmaechtigterErgebnisse");
const vollmachtBevollmaechtigterAuswahl    = document.getElementById("vollmachtBevollmaechtigterAuswahl");

if (btnVollmachtBevollmaechtigterSuchen) {
  btnVollmachtBevollmaechtigterSuchen.addEventListener("click", async () => {
    const name = vollmachtBevollmaechtigterSuche?.value?.trim() || "";
    if (name.length < 2) {
      if (vollmachtBevollmaechtigterErgebnisse) vollmachtBevollmaechtigterErgebnisse.innerHTML = "<div class='muted'>Bitte mindestens 2 Zeichen eingeben.</div>";
      return;
    }
    if (vollmachtBevollmaechtigterErgebnisse) vollmachtBevollmaechtigterErgebnisse.innerHTML = "<div class='muted'>Suche läuft…</div>";
    window._delegationSuchKontext = "vollmacht_bevollmaechtigter";
    await nuiAufruf("hm_bp:delegation_online_spieler_suchen", { name });
  });
}

// Vollmacht anlegen
const btnVollmachtAnlegen  = document.getElementById("btnVollmachtAnlegen");
const vollmachtAnlegenMeta = document.getElementById("vollmachtAnlegenMeta");
const vollmachtNeuTyp      = document.getElementById("vollmachtNeuTyp");

if (btnVollmachtAnlegen) {
  btnVollmachtAnlegen.addEventListener("click", async () => {
    if (!vollmachtNeuTyp?.value) {
      if (vollmachtAnlegenMeta) vollmachtAnlegenMeta.textContent = "Bitte einen Vollmacht-Typ auswählen.";
      return;
    }
    if (!vollmachtAuftraggeberSpieler) {
      if (vollmachtAnlegenMeta) vollmachtAnlegenMeta.textContent = "Bitte den Auftraggeber auswählen.";
      return;
    }
    if (!vollmachtBevollmaechtigterSpieler) {
      if (vollmachtAnlegenMeta) vollmachtAnlegenMeta.textContent = "Bitte den Bevollmächtigten auswählen.";
      return;
    }
    if (vollmachtAnlegenMeta) vollmachtAnlegenMeta.textContent = "Vollmacht wird angelegt…";
    await nuiAufruf("hm_bp:delegation_vollmacht_anlegen", {
      typ: vollmachtNeuTyp.value,
      auftraggeber_source: vollmachtAuftraggeberSpieler.source,
      bevollmaechtigter_source: vollmachtBevollmaechtigterSpieler.source,
    });
  });
}

// Vollmachten laden
const btnVollmachtenLaden  = document.getElementById("btnVollmachtenLaden");
const vollmachtNurAktiv    = document.getElementById("vollmachtenNurAktiv");
const vollmachtenListe     = document.getElementById("vollmachtenListe");

async function vollmachtenListeLaden() {
  if (vollmachtenListe) vollmachtenListe.innerHTML = "<div class='muted'>Lade Vollmachten…</div>";
  const nurAktiv = vollmachtNurAktiv ? vollmachtNurAktiv.checked : true;
  await nuiAufruf("hm_bp:delegation_vollmachten_laden", { nur_aktiv: nurAktiv });
}

if (btnVollmachtenLaden) {
  btnVollmachtenLaden.addEventListener("click", () => vollmachtenListeLaden());
}
if (vollmachtNurAktiv) {
  vollmachtNurAktiv.addEventListener("change", () => vollmachtenListeLaden());
}

// Vollmacht-Verwaltung: Admin-Subtab
const VOLLMACHT_SUBTAB = "Vollmachten";
const adminVollmachtenPanel = document.getElementById("adminVollmachtenPanel");

// Vollmacht-Subtab in adminSubtabSetzen einbinden
const _origAdminSubtabSetzen = typeof adminSubtabSetzen === "function" ? adminSubtabSetzen : null;
// Wir patchen die Funktion nach Definition
(function patchAdminSubtab() {
  // Da adminSubtabSetzen nach diesem Abschnitt definiert ist, führen wir den Patch
  // in einem MutationObserver/Timeout durch oder wir ergänzen direkt im Subtab-Click-Listener.
})();

// Delegation Server-Antworten
window.addEventListener("message", function(event) {
  const msg = event.data || {};

  // Spieler-Suchergebnis (für alle Delegation-Kontexte)
  if (msg.typ === "hm_bp:delegation:online_spieler_ergebnis") {
    const payload = msg.payload || {};
    const kontext = window._delegationSuchKontext || "delegation";
    window._delegationSuchKontext = null;

    if (!payload.ok) {
      const fehlermsg = payload.fehler?.nachricht || "Suche fehlgeschlagen.";
      if (kontext === "hilfsantrag") {
        if (hilfsantragSuchMeta) hilfsantragSuchMeta.textContent = fehlermsg;
      } else if (kontext === "vollmacht_auftraggeber") {
        if (vollmachtAuftraggeberErgebnisse) vollmachtAuftraggeberErgebnisse.innerHTML = `<div class='muted'>${escapeHtml(fehlermsg)}</div>`;
      } else if (kontext === "vollmacht_bevollmaechtigter") {
        if (vollmachtBevollmaechtigterErgebnisse) vollmachtBevollmaechtigterErgebnisse.innerHTML = `<div class='muted'>${escapeHtml(fehlermsg)}</div>`;
      } else {
        if (delegationSuchMeta) delegationSuchMeta.textContent = fehlermsg;
      }
      return;
    }

    const spielerListe = payload.spieler || [];

    if (kontext === "hilfsantrag") {
      if (hilfsantragSuchMeta) hilfsantragSuchMeta.textContent = spielerListe.length === 0 ? "Kein online Spieler gefunden." : `${spielerListe.length} Treffer.`;
      delegationSpielerListeRendern(hilfsantragSuchergebnisse, spielerListe, (sp) => {
        hilfsantragAusgewaehlterSpieler = sp;
        if (hilfsantragAuswahlAnzeige) hilfsantragAuswahlAnzeige.textContent = `Ausgewählt: ${sp.name}`;
        if (hilfsantragSuchergebnisse) hilfsantragSuchergebnisse.innerHTML = "";
      });
    } else if (kontext === "vollmacht_auftraggeber") {
      delegationSpielerListeRendern(vollmachtAuftraggeberErgebnisse, spielerListe, (sp) => {
        vollmachtAuftraggeberSpieler = sp;
        if (vollmachtAuftraggeberAuswahl) vollmachtAuftraggeberAuswahl.textContent = `Ausgewählt: ${sp.name}`;
        if (vollmachtAuftraggeberErgebnisse) vollmachtAuftraggeberErgebnisse.innerHTML = "";
      });
    } else if (kontext === "vollmacht_bevollmaechtigter") {
      delegationSpielerListeRendern(vollmachtBevollmaechtigterErgebnisse, spielerListe, (sp) => {
        vollmachtBevollmaechtigterSpieler = sp;
        if (vollmachtBevollmaechtigterAuswahl) vollmachtBevollmaechtigterAuswahl.textContent = `Ausgewählt: ${sp.name}`;
        if (vollmachtBevollmaechtigterErgebnisse) vollmachtBevollmaechtigterErgebnisse.innerHTML = "";
      });
    } else {
      // Standard: Delegation im Bürger-Formular
      if (delegationSuchMeta) delegationSuchMeta.textContent = spielerListe.length === 0 ? "Kein online Spieler gefunden." : `${spielerListe.length} Treffer.`;
      delegationSpielerListeRendern(delegationSuchergebnisse, spielerListe, (sp) => {
        delegationAusgewaehlterSpieler = sp;
        if (delegationAuswahlAnzeige) delegationAuswahlAnzeige.textContent = `Ausgewählt: ${sp.name}`;
        if (delegationSuchergebnisse) delegationSuchergebnisse.innerHTML = "";
        if (delegationSuchMeta) delegationSuchMeta.textContent = "";
      });
    }
    return;
  }

  // Vollmacht anlegen Antwort
  if (msg.typ === "hm_bp:delegation:vollmacht_anlegen_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) {
      if (vollmachtAnlegenMeta) vollmachtAnlegenMeta.textContent = `Fehler: ${payload.fehler?.nachricht || "Unbekannter Fehler."}`;
    } else {
      if (vollmachtAnlegenMeta) vollmachtAnlegenMeta.textContent = payload.ergebnis?.nachricht || "Vollmacht erfolgreich angelegt.";
      // Felder zurücksetzen
      if (vollmachtNeuTyp) vollmachtNeuTyp.value = "";
      if (vollmachtAuftraggeberSuche) vollmachtAuftraggeberSuche.value = "";
      if (vollmachtBevollmaechtigterSuche) vollmachtBevollmaechtigterSuche.value = "";
      if (vollmachtAuftraggeberAuswahl) vollmachtAuftraggeberAuswahl.textContent = "";
      if (vollmachtBevollmaechtigterAuswahl) vollmachtBevollmaechtigterAuswahl.textContent = "";
      vollmachtAuftraggeberSpieler = null;
      vollmachtBevollmaechtigterSpieler = null;
      vollmachtenListeLaden();
    }
    return;
  }

  // Vollmacht widerrufen Antwort
  if (msg.typ === "hm_bp:delegation:vollmacht_widerrufen_antwort") {
    const payload = msg.payload || {};
    if (!payload.ok) {
      fehlerAnzeigen(payload.fehler?.nachricht || "Vollmacht widerrufen fehlgeschlagen.");
    } else {
      vollmachtenListeLaden();
    }
    return;
  }

  // Vollmachten Liste Antwort
  if (msg.typ === "hm_bp:delegation:vollmachten_ergebnis") {
    const payload = msg.payload || {};
    if (!vollmachtenListe) return;
    if (!payload.ok) {
      vollmachtenListe.innerHTML = `<div class='muted'>Fehler: ${escapeHtml(payload.fehler?.nachricht || "Laden fehlgeschlagen.")}</div>`;
      return;
    }
    const liste = payload.liste || [];
    if (liste.length === 0) {
      vollmachtenListe.innerHTML = "<div class='muted'>Keine Vollmachten gefunden.</div>";
      return;
    }
    const typLabels = {
      buerger_anwalt:   "Bürger ↔ Bevollmächtigter",
      firma_vertreter:  "Firma ↔ Firmenvertreter",
    };
    vollmachtenListe.innerHTML = "";
    liste.forEach(vm => {
      const div = document.createElement("div");
      div.className = "liste-eintrag";
      div.style.cssText = "padding:8px; border-bottom:1px solid #eee; display:flex; align-items:center; justify-content:space-between; gap:8px;";
      const info = document.createElement("div");
      info.innerHTML = `
        <strong>${escapeHtml(typLabels[vm.vollmacht_typ] || vm.vollmacht_typ)}</strong><br>
        <span class="muted">Auftraggeber: ${escapeHtml(vm.auftraggeber_name)}</span> →
        <span class="muted">Bevollmächtigter: ${escapeHtml(vm.bevollmaechtigter_name)}</span><br>
        <span class="muted" style="font-size:0.85em;">Erteilt von ${escapeHtml(vm.erteilt_von_name)} am ${escapeHtml(vm.erstellt_at || "")}</span>
        ${!vm.aktiv ? `<span class="muted" style="color:#e74c3c;"> – widerrufen von ${escapeHtml(vm.widerrufen_von_name || "")} am ${escapeHtml(vm.widerrufen_at || "")}</span>` : ""}
      `;
      div.appendChild(info);
      if (vm.aktiv) {
        const btnWiderrufen = document.createElement("button");
        btnWiderrufen.type = "button";
        btnWiderrufen.className = "btn btn-secondary";
        btnWiderrufen.textContent = "Widerrufen";
        btnWiderrufen.style.cssText = "flex-shrink:0; color:#e74c3c; border-color:#e74c3c;";
        btnWiderrufen.addEventListener("click", async () => {
          if (!confirm(`Vollmacht zwischen "${vm.auftraggeber_name}" und "${vm.bevollmaechtigter_name}" wirklich widerrufen?`)) return;
          await nuiAufruf("hm_bp:delegation_vollmacht_widerrufen", { vollmacht_id: vm.id });
        });
        div.appendChild(btnWiderrufen);
      }
      vollmachtenListe.appendChild(div);
    });
    return;
  }
});

// Beim Schließen des UI: Delegation-State zurücksetzen
window.addEventListener("message", function(e) {
  if ((e.data || {}).typ === "hm_bp:ui_schliessen") {
    delegationAusgewaehlterSpieler = null;
    hilfsantragAusgewaehlterSpieler = null;
    vollmachtAuftraggeberSpieler = null;
    vollmachtBevollmaechtigterSpieler = null;
    if (delegationAuswahlAnzeige) delegationAuswahlAnzeige.textContent = "";
    if (delegationSuchergebnisse) delegationSuchergebnisse.innerHTML = "";
    if (hilfsantragAuswahlAnzeige) hilfsantragAuswahlAnzeige.textContent = "";
    if (hilfsantragSuchergebnisse) hilfsantragSuchergebnisse.innerHTML = "";
    // PR6: Ops-State zurücksetzen
    opsImAuftragAusgewaehlterSpieler = null;
    opsImAuftragAusgewaehlterFormularId = null;
  }
});

// ==========================
// PR6: Bürger-Suche (eigene Anträge)
// ==========================

function buergerSucheStatusListeFuellen() {
  if (!buergerSucheStatus) return;
  buergerSucheStatus.innerHTML = "<option value=\"\">Alle Status</option>";
  for (const s of statusListeAktuell) {
    const o = document.createElement("option");
    o.value = s.id;
    o.textContent = s.label || s.id;
    buergerSucheStatus.appendChild(o);
  }
}

async function buergerSuchen(seite) {
  if (!buergerSucheMeta) return;
  seite = seite || 1;
  const payload = {
    query: (buergerSucheQuery && buergerSucheQuery.value.trim()) || "",
    status: (buergerSucheStatus && buergerSucheStatus.value) || "",
    dateFrom: (buergerSucheDateFrom && buergerSucheDateFrom.value) || "",
    dateTo: (buergerSucheDateTo && buergerSucheDateTo.value) || "",
    sortBy: (buergerSucheSortBy && buergerSucheSortBy.value) || "updated_at",
    sortDir: (buergerSucheSortDir && buergerSucheSortDir.value) || "DESC",
    page: seite,
  };
  buergerSucheAktuelleSeite = seite;
  buergerSucheLetztesPayload = payload;
  buergerSucheMeta.textContent = "Suche läuft…";
  await nuiAufruf("hm_bp:buerger_suchen", payload);
}

function buergerSuchePaginierungAktualisieren(total, seite, gesamtSeiten) {
  if (!buergerSuchePaginierung) return;
  if (!total || gesamtSeiten <= 1) {
    buergerSuchePaginierung.style.display = "none";
    return;
  }
  buergerSuchePaginierung.style.display = "flex";
  if (buergerSeiteInfo) buergerSeiteInfo.textContent = `Seite ${seite} von ${gesamtSeiten}`;
  if (buergerGesamtInfo) buergerGesamtInfo.textContent = `${total} Ergebnis${total === 1 ? "" : "se"}`;
  if (btnBuergerSeiteZurueck) btnBuergerSeiteZurueck.disabled = seite <= 1;
  if (btnBuergerSeiteWeiter) btnBuergerSeiteWeiter.disabled = seite >= gesamtSeiten;
}

function buergerSuchErgebnisseRendern(liste) {
  if (!buergerSuchErgebnisse) return;
  if (!liste || liste.length === 0) {
    buergerSuchErgebnisse.innerHTML = "<div class='muted'>Keine Anträge gefunden.</div>";
    return;
  }
  buergerSuchErgebnisse.innerHTML = "";
  liste.forEach(a => {
    const div = document.createElement("div");
    div.className = "liste-eintrag";
    div.style.cssText = "padding:8px; border-bottom:1px solid #eee; cursor:pointer;";
    div.innerHTML = `
      <strong>${escapeHtml(a.public_id || a.id)}</strong>
      <span class="muted" style="margin-left:8px;">${escapeHtml(a.form_id || "")}</span><br>
      <span class="muted">Status: ${escapeHtml(a.status || "")}</span>
      <span class="muted" style="margin-left:8px;">Erstellt: ${escapeHtml(String(a.created_at || "").substring(0, 10))}</span>
    `;
    div.addEventListener("click", () => {
      ausgewaehlterBuergerAntragId = a.id;
      nuiAufruf("hm_bp:antrag_details_mein_laden", { antragId: a.id });
    });
    buergerSuchErgebnisse.appendChild(div);
  });
}

// Antwort vom Server für Bürger-Suche
window.addEventListener("message", function(e) {
  const d = e.data || {};
  if (d.typ !== "hm_bp:antraege:suchen_antwort") return;
  const payload = d.payload || {};
  if (!payload.ok) {
    if (buergerSucheMeta) buergerSucheMeta.textContent = "Fehler: " + (payload.fehler?.nachricht || "Suche fehlgeschlagen.");
    return;
  }
  const res = payload.res || {};
  if (buergerSucheMeta) buergerSucheMeta.textContent = `${res.total || 0} Ergebnis${(res.total || 0) === 1 ? "" : "se"} gefunden.`;
  buergerSucheGesamtSeiten = res.gesamtSeiten || 1;
  buergerSuchePaginierungAktualisieren(res.total || 0, buergerSucheAktuelleSeite, buergerSucheGesamtSeiten);
  buergerSuchErgebnisseRendern(res.liste || []);
});

// Bürger-Suche: Event-Listener
if (btnBuergerSuchen) btnBuergerSuchen.addEventListener("click", () => buergerSuchen(1));
if (btnBuergerSucheReset) {
  btnBuergerSucheReset.addEventListener("click", () => {
    if (buergerSucheQuery) buergerSucheQuery.value = "";
    if (buergerSucheStatus) buergerSucheStatus.value = "";
    if (buergerSucheDateFrom) buergerSucheDateFrom.value = "";
    if (buergerSucheDateTo) buergerSucheDateTo.value = "";
    if (buergerSucheSortBy) buergerSucheSortBy.value = "updated_at";
    if (buergerSucheSortDir) buergerSucheSortDir.value = "DESC";
    if (buergerSucheMeta) buergerSucheMeta.textContent = "Filter zurückgesetzt.";
    if (buergerSuchErgebnisse) buergerSuchErgebnisse.innerHTML = "";
    if (buergerSuchePaginierung) buergerSuchePaginierung.style.display = "none";
    buergerSucheLetztesPayload = null;
  });
}
if (btnBuergerSeiteZurueck) {
  btnBuergerSeiteZurueck.addEventListener("click", async () => {
    if (buergerSucheAktuelleSeite > 1) await buergerSuchen(buergerSucheAktuelleSeite - 1);
  });
}
if (btnBuergerSeiteWeiter) {
  btnBuergerSeiteWeiter.addEventListener("click", async () => {
    if (buergerSucheAktuelleSeite < buergerSucheGesamtSeiten) await buergerSuchen(buergerSucheAktuelleSeite + 1);
  });
}

// ==========================
// PR6: Admin-Ops Panel
// ==========================

function opsSubtabSetzen(tab) {
  opsAktuellerSubtab = tab;
  document.querySelectorAll(".ops-subtab").forEach(btn => {
    btn.classList.toggle("active", btn.dataset.opstab === tab);
  });
  const bereiche = {
    suche: document.getElementById("opsBereichSuche"),
    aktionen: document.getElementById("opsBereichAktionen"),
    imauftrag: document.getElementById("opsBereichImAuftrag"),
  };
  for (const [key, el] of Object.entries(bereiche)) {
    if (el) el.style.display = key === tab ? "" : "none";
  }
}

// Ops-Suche
async function opsSuchen(seite) {
  const metaEl = document.getElementById("opsSucheMeta");
  if (metaEl) metaEl.textContent = "Suche läuft…";
  seite = seite || 1;
  const payload = {
    query: (document.getElementById("opsSearchQuery")?.value || "").trim(),
    kategorieId: (document.getElementById("opsSearchKategorie")?.value || "").trim(),
    formularId: (document.getElementById("opsSearchFormular")?.value || "").trim(),
    status: document.getElementById("opsSearchStatus")?.value || "",
    zahlungStatus: document.getElementById("opsSearchGebuehr")?.value || "",
    dateFrom: document.getElementById("opsSearchDateFrom")?.value || "",
    dateTo: document.getElementById("opsSearchDateTo")?.value || "",
    sortBy: document.getElementById("opsSearchSortBy")?.value || "updated_at",
    sortDir: document.getElementById("opsSearchSortDir")?.value || "DESC",
    page: seite,
  };
  opsSucheAktuelleSeite = seite;
  opsSucheLetztesPayload = payload;
  await nuiAufruf("hm_bp:admin_ops_suchen", payload);
}

function opsPaginierungAktualisieren(total, seite, gesamtSeiten) {
  const pagEl = document.getElementById("opsPaginierung");
  if (!pagEl) return;
  if (!total || gesamtSeiten <= 1) { pagEl.style.display = "none"; return; }
  pagEl.style.display = "flex";
  const seiteInfoEl = document.getElementById("opsSeiteInfo");
  const gesamtInfoEl = document.getElementById("opsGesamtInfo");
  if (seiteInfoEl) seiteInfoEl.textContent = `Seite ${seite} von ${gesamtSeiten}`;
  if (gesamtInfoEl) gesamtInfoEl.textContent = `${total} Ergebnis${total === 1 ? "" : "se"}`;
  const btnZurueck = document.getElementById("btnOpsSeiteZurueck");
  const btnWeiter = document.getElementById("btnOpsSeiteWeiter");
  if (btnZurueck) btnZurueck.disabled = seite <= 1;
  if (btnWeiter) btnWeiter.disabled = seite >= gesamtSeiten;
}

function opsSuchErgebnisseRendern(liste) {
  const el = document.getElementById("opsSuchErgebnisse");
  if (!el) return;
  if (!liste || liste.length === 0) { el.innerHTML = "<div class='muted'>Keine Anträge gefunden.</div>"; return; }
  el.innerHTML = "";
  liste.forEach(a => {
    const div = document.createElement("div");
    div.className = "liste-eintrag";
    div.style.cssText = "padding:8px; border-bottom:1px solid #eee; display:flex; align-items:center; gap:12px;";
    const infoDiv = document.createElement("div");
    infoDiv.style.flex = "1";
    infoDiv.innerHTML = `
      <strong>${escapeHtml(a.public_id || String(a.id))}</strong>
      <span class="muted" style="margin-left:6px;">${escapeHtml(a.form_id || "")}</span>
      <span class="muted" style="margin-left:6px;">Kat: ${escapeHtml(a.category_id || "")}</span><br>
      <span class="muted">Bürger: ${escapeHtml(a.citizen_name || "")}</span>
      <span class="muted" style="margin-left:8px;">Status: ${escapeHtml(a.status || "")}</span>
      <span class="muted" style="margin-left:8px;">${escapeHtml(String(a.created_at || "").substring(0, 10))}</span>
    `;
    const copyBtn = document.createElement("button");
    copyBtn.type = "button";
    copyBtn.className = "btn btn-secondary";
    copyBtn.style.cssText = "font-size:0.85em; padding:4px 8px;";
    copyBtn.textContent = "ID übernehmen";
    copyBtn.addEventListener("click", (ev) => {
      ev.stopPropagation();
      const antragIdEl = document.getElementById("opsAntragId");
      if (antragIdEl) antragIdEl.value = a.id;
      opsSubtabSetzen("aktionen");
    });
    div.appendChild(infoDiv);
    div.appendChild(copyBtn);
    el.appendChild(div);
  });
}

// Ops-Suche: NUI-Antwort
window.addEventListener("message", function(e) {
  const d = e.data || {};
  if (d.typ !== "hm_bp:admin_ops:suchen_antwort") return;
  const payload = d.payload || {};
  const metaEl = document.getElementById("opsSucheMeta");
  if (!payload.ok) {
    if (metaEl) metaEl.textContent = "Fehler: " + (payload.fehler?.nachricht || "Suche fehlgeschlagen.");
    return;
  }
  const res = payload.res || {};
  if (metaEl) metaEl.textContent = `${res.total || 0} Ergebnis${(res.total || 0) === 1 ? "" : "se"} gefunden.`;
  opsSucheGesamtSeiten = res.gesamtSeiten || 1;
  opsPaginierungAktualisieren(res.total || 0, opsSucheAktuelleSeite, opsSucheGesamtSeiten);
  opsSuchErgebnisseRendern(res.liste || []);
});

// Ops-Suche: Buttons
const btnOpsSuchen = document.getElementById("btnOpsSuchen");
const btnOpsSucheReset = document.getElementById("btnOpsSucheReset");
const btnOpsSeiteZurueck = document.getElementById("btnOpsSeiteZurueck");
const btnOpsSeiteWeiter = document.getElementById("btnOpsSeiteWeiter");
if (btnOpsSuchen) btnOpsSuchen.addEventListener("click", () => opsSuchen(1));
if (btnOpsSucheReset) {
  btnOpsSucheReset.addEventListener("click", () => {
    ["opsSearchQuery","opsSearchKategorie","opsSearchFormular","opsSearchDateFrom","opsSearchDateTo"].forEach(id => {
      const el = document.getElementById(id); if (el) el.value = "";
    });
    ["opsSearchStatus","opsSearchGebuehr"].forEach(id => {
      const el = document.getElementById(id); if (el) el.value = "";
    });
    const metaEl = document.getElementById("opsSucheMeta");
    if (metaEl) metaEl.textContent = "Filter zurückgesetzt.";
    const ergebnisse = document.getElementById("opsSuchErgebnisse");
    if (ergebnisse) ergebnisse.innerHTML = "";
    const pagEl = document.getElementById("opsPaginierung");
    if (pagEl) pagEl.style.display = "none";
  });
}
if (btnOpsSeiteZurueck) {
  btnOpsSeiteZurueck.addEventListener("click", async () => {
    if (opsSucheAktuelleSeite > 1) await opsSuchen(opsSucheAktuelleSeite - 1);
  });
}
if (btnOpsSeiteWeiter) {
  btnOpsSeiteWeiter.addEventListener("click", async () => {
    if (opsSucheAktuelleSeite < opsSucheGesamtSeiten) await opsSuchen(opsSucheAktuelleSeite + 1);
  });
}

// Ops-Subtabs
document.querySelectorAll(".ops-subtab").forEach(btn => {
  btn.addEventListener("click", () => opsSubtabSetzen(btn.dataset.opstab));
});

// Ops: Wiederherstellen
const btnOpsWiederherstellen = document.getElementById("btnOpsWiederherstellen");
if (btnOpsWiederherstellen) {
  btnOpsWiederherstellen.addEventListener("click", async () => {
    const antragId = (document.getElementById("opsAntragId")?.value || "").trim();
    const grund = (document.getElementById("opsWiederherstellenGrund")?.value || "").trim();
    const metaEl = document.getElementById("opsWiederherstellenMeta");
    if (!antragId) { if (metaEl) metaEl.textContent = "Antrags-ID fehlt."; return; }
    if (!grund) { if (metaEl) metaEl.textContent = "Begründung fehlt."; return; }
    if (metaEl) metaEl.textContent = "Wird verarbeitet…";
    const res = await nuiAufruf("hm_bp:admin_ops_wiederherstellen", { antragId, grund });
    if (metaEl) metaEl.textContent = res.ok ? "✓ Antrag erfolgreich wiederhergestellt." : "Fehler: " + (res.fehler?.nachricht || "Unbekannter Fehler.");
  });
}

// Ops: Status überschreiben
const btnOpsStatusOverride = document.getElementById("btnOpsStatusOverride");
if (btnOpsStatusOverride) {
  btnOpsStatusOverride.addEventListener("click", async () => {
    const antragId = (document.getElementById("opsAntragId")?.value || "").trim();
    const neuerStatus = document.getElementById("opsStatusOverrideSelect")?.value || "";
    const grund = (document.getElementById("opsStatusOverrideGrund")?.value || "").trim();
    const metaEl = document.getElementById("opsStatusOverrideMeta");
    if (!antragId) { if (metaEl) metaEl.textContent = "Antrags-ID fehlt."; return; }
    if (!neuerStatus) { if (metaEl) metaEl.textContent = "Bitte Status wählen."; return; }
    if (!grund) { if (metaEl) metaEl.textContent = "Begründung fehlt."; return; }
    if (metaEl) metaEl.textContent = "Wird verarbeitet…";
    const res = await nuiAufruf("hm_bp:admin_ops_status_override", { antragId, neuerStatus, grund });
    if (metaEl) metaEl.textContent = res.ok ? "✓ Status erfolgreich überschrieben." : "Fehler: " + (res.fehler?.nachricht || "Unbekannter Fehler.");
  });
}

// Ops: Verschieben
const btnOpsVerschieben = document.getElementById("btnOpsVerschieben");
if (btnOpsVerschieben) {
  btnOpsVerschieben.addEventListener("click", async () => {
    const antragId = (document.getElementById("opsAntragId")?.value || "").trim();
    const neuKategorieId = (document.getElementById("opsVerschiebenKategorie")?.value || "").trim();
    const neuFormularId = (document.getElementById("opsVerschiebenFormular")?.value || "").trim();
    const grund = (document.getElementById("opsVerschiebenGrund")?.value || "").trim();
    const metaEl = document.getElementById("opsVerschiebenMeta");
    if (!antragId) { if (metaEl) metaEl.textContent = "Antrags-ID fehlt."; return; }
    if (!neuKategorieId && !neuFormularId) { if (metaEl) metaEl.textContent = "Mindestens Kategorie oder Formular muss angegeben werden."; return; }
    if (!grund) { if (metaEl) metaEl.textContent = "Begründung fehlt."; return; }
    if (metaEl) metaEl.textContent = "Wird verarbeitet…";
    const res = await nuiAufruf("hm_bp:admin_ops_verschieben", { antragId, neuKategorieId, neuFormularId, grund });
    if (metaEl) metaEl.textContent = res.ok ? "✓ Antrag erfolgreich verschoben." : "Fehler: " + (res.fehler?.nachricht || "Unbekannter Fehler.");
  });
}

// Ops: Hart löschen
const btnOpsHartLoeschen = document.getElementById("btnOpsHartLoeschen");
if (btnOpsHartLoeschen) {
  btnOpsHartLoeschen.addEventListener("click", async () => {
    const antragId = (document.getElementById("opsAntragId")?.value || "").trim();
    const grund = (document.getElementById("opsHartLoeschenGrund")?.value || "").trim();
    const metaEl = document.getElementById("opsHartLoeschenMeta");
    if (!antragId) { if (metaEl) metaEl.textContent = "Antrags-ID fehlt."; return; }
    if (!grund) { if (metaEl) metaEl.textContent = "Begründung fehlt."; return; }
    // Sicherheits-Bestätigung ohne direkte Eingabe im Dialog-Text
    if (!confirm("Antrag wirklich ENDGÜLTIG löschen? Diese Aktion kann NICHT rückgängig gemacht werden!")) return;
    if (metaEl) metaEl.textContent = "Wird verarbeitet…";
    const res = await nuiAufruf("hm_bp:admin_ops_hartloeschen", { antragId, grund });
    if (metaEl) metaEl.textContent = res.ok ? "✓ Antrag endgültig gelöscht." : "Fehler: " + (res.fehler?.nachricht || "Unbekannter Fehler.");
  });
}

// Ops: Im Auftrag erstellen – Spieler-Suche
const btnOpsImAuftragSuchen = document.getElementById("btnOpsImAuftragSuchen");
if (btnOpsImAuftragSuchen) {
  btnOpsImAuftragSuchen.addEventListener("click", async () => {
    const name = (document.getElementById("opsImAuftragSuchname")?.value || "").trim();
    const metaEl = document.getElementById("opsImAuftragSuchMeta");
    const ergebnisseEl = document.getElementById("opsImAuftragErgebnisse");
    if (!name || name.length < 2) { if (metaEl) metaEl.textContent = "Min. 2 Zeichen eingeben."; return; }
    if (metaEl) metaEl.textContent = "Suche läuft…";
    if (ergebnisseEl) ergebnisseEl.innerHTML = "";
    const res = await nuiAufruf("hm_bp:delegation_online_spieler_suchen", { name });
    if (!res.ok) { if (metaEl) metaEl.textContent = "Fehler: " + (res.fehler?.nachricht || "Suche fehlgeschlagen."); return; }
    const spieler = res.spieler || [];
    if (metaEl) metaEl.textContent = spieler.length === 0 ? "Kein online Spieler mit diesem Namen gefunden." : `${spieler.length} Spieler gefunden.`;
    if (ergebnisseEl) {
      ergebnisseEl.innerHTML = "";
      spieler.forEach(sp => {
        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "btn btn-secondary";
        btn.style.cssText = "width:100%; text-align:left; margin-bottom:4px;";
        btn.textContent = sp.name;
        btn.addEventListener("click", () => {
          opsImAuftragAusgewaehlterSpieler = { source: sp.source, name: sp.name };
          const auswahlEl = document.getElementById("opsImAuftragAuswahl");
          if (auswahlEl) auswahlEl.textContent = `Ausgewählt: ${sp.name}`;
          // Formularliste für Im-Auftrag laden
          opsImAuftragFormularListeLaden();
        });
        ergebnisseEl.appendChild(btn);
      });
    }
  });
}

async function opsImAuftragFormularListeLaden() {
  const selectEl = document.getElementById("opsImAuftragFormular");
  if (!selectEl) return;
  selectEl.innerHTML = "<option value=\"\">– Lade Formulare… –</option>";
  // Alle verfügbaren Formulare aus globalem State laden (falls vorhanden)
  // Einfache Fallback-Lösung: nutze Kategorien-Formulare
  selectEl.innerHTML = "<option value=\"\">– Bitte Formular-ID manuell eingeben –</option>";
  const felderEl = document.getElementById("opsImAuftragFelder");
  if (felderEl) felderEl.style.display = "none";
}

// Ops: Im Auftrag - Formular laden wenn ID eingegeben
const opsImAuftragFormularSelect = document.getElementById("opsImAuftragFormular");
// Fallback: Formular-ID als Text-Input direkt nach dem Select
const opsImAuftragFormularInput = (() => {
  const el = document.createElement("input");
  el.type = "text";
  el.id = "opsImAuftragFormularInput";
  el.placeholder = "Formular-ID direkt eingeben (z.B. general_request)…";
  el.style.marginTop = "6px";
  if (opsImAuftragFormularSelect) {
    opsImAuftragFormularSelect.parentNode.insertBefore(el, opsImAuftragFormularSelect.nextSibling);
  }
  return el;
})();

// Ops: Im Auftrag Formular laden
const btnOpsImAuftragSchema = document.createElement("button");
btnOpsImAuftragSchema.type = "button";
btnOpsImAuftragSchema.className = "btn btn-secondary";
btnOpsImAuftragSchema.textContent = "Formular laden";
btnOpsImAuftragSchema.style.marginTop = "6px";
if (opsImAuftragFormularInput && opsImAuftragFormularInput.parentNode) {
  opsImAuftragFormularInput.parentNode.insertBefore(btnOpsImAuftragSchema, opsImAuftragFormularInput.nextSibling);
}
btnOpsImAuftragSchema.addEventListener("click", async () => {
  const formularId = opsImAuftragFormularInput.value.trim();
  const metaEl = document.getElementById("opsImAuftragErstellenMeta");
  if (!formularId) {
    if (metaEl) metaEl.textContent = "Bitte Formular-ID eingeben.";
    return;
  }
  const res = await nuiAufruf("hm_bp:formular_schema_laden", { formularId });
  if (!res.ok || !res.schema) {
    if (metaEl) metaEl.textContent = "Formular nicht gefunden oder Schema konnte nicht geladen werden.";
    return;
  }
  opsImAuftragAusgewaehlterFormularId = formularId;
  if (metaEl) metaEl.textContent = "";
  const felderEl = document.getElementById("opsImAuftragFelder");
  const containerEl = document.getElementById("opsImAuftragFelderContainer");
  if (felderEl) felderEl.style.display = "";
  if (containerEl) {
    containerEl.innerHTML = "";
    schemaRendern_inContainer(res.schema, containerEl);
  }
});

function schemaRendern_inContainer(schema, container) {
  if (!schema || !container) return;
  container.innerHTML = "";
  (schema.felder || schema.fields || []).forEach(feld => {
    const el = feldElementErstellen(feld);
    if (el) container.appendChild(el);
  });
}

// Ops: Im Auftrag Antrag einreichen
const btnOpsImAuftragErstellen = document.getElementById("btnOpsImAuftragErstellen");
if (btnOpsImAuftragErstellen) {
  btnOpsImAuftragErstellen.addEventListener("click", async () => {
    const metaEl = document.getElementById("opsImAuftragErstellenMeta");
    if (!opsImAuftragAusgewaehlterSpieler) { if (metaEl) metaEl.textContent = "Bitte zuerst einen Bürger auswählen."; return; }
    if (!opsImAuftragAusgewaehlterFormularId) { if (metaEl) metaEl.textContent = "Bitte Formular laden."; return; }
    const grund = (document.getElementById("opsImAuftragGrund")?.value || "").trim();
    if (!grund) { if (metaEl) metaEl.textContent = "Begründung fehlt."; return; }
    const containerEl = document.getElementById("opsImAuftragFelderContainer");
    const antworten = containerEl ? antwortenEinsammeln_inContainer(containerEl) : {};
    if (metaEl) metaEl.textContent = "Wird eingereicht…";
    const res = await nuiAufruf("hm_bp:admin_ops_im_auftrag_erstellen", {
      zielIngameName: opsImAuftragAusgewaehlterSpieler.name,
      zielSource: opsImAuftragAusgewaehlterSpieler.source,
      formularId: opsImAuftragAusgewaehlterFormularId,
      antworten,
      grund,
    });
    if (metaEl) metaEl.textContent = res.ok ? "✓ Antrag erfolgreich im Auftrag eingereicht." : "Fehler: " + (res.fehler?.nachricht || "Unbekannter Fehler.");
  });
}

function antwortenEinsammeln_inContainer(container) {
  const antworten = {};
  if (!container) return antworten;
  container.querySelectorAll("[data-field-id]").forEach(el => {
    const id = el.dataset.fieldId;
    if (el.type === "checkbox") antworten[id] = el.checked;
    else if (el.tagName === "SELECT" && el.multiple) {
      antworten[id] = Array.from(el.selectedOptions).map(o => o.value);
    } else {
      antworten[id] = el.value;
    }
  });
  return antworten;
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