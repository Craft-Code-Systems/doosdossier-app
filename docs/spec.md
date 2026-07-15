# Spec — DoosDossier

> Detailed functional and non-functional specification.
>
> Deze Spec bestaat omdat het domein dicht genoeg is dat één
> referentiedocument echt helpt (grond c uit
> [Decision 0005 van Colophon](https://github.com/Craft-Code-Systems/colophon/blob/main/docs/adr/0005-coverage-mapping.md)):
> vier koepel-formaten, wettelijke classificaties en temporele regels
> laten zich niet in Brief-bullets vangen.

---

## Functional requirements

Elke requirement heeft een stabiel identifier (`F-NN`) voor referentie
vanuit issues, Decisions en tests.

### F-01 — Verpakkingscatalogus op componentniveau

**Description:** beheer van verpakkingscomponenten (doos, vulmateriaal,
tape, label, seal) met per component: materiaalcategorie, gewicht,
recycled content %, PFAS-flag, herbruikbaar j/n, leverancier en
databron.

**Acceptance:** component aanmaken/wijzigen/archiveren; elke waarde
heeft een bronvermelding; wijzigingen verschijnen in de audit trail
(F-13).

**Priority:** must-have

**Notes:** materiaaltaxonomie versioned (N-02); extensible attributen
via JSONB voor toekomstige delegated-act-velden.

### F-02 — Defaults-bibliotheek

**Description:** vooringevulde bibliotheek van standaardverpakkingen
(FEFCO-dozen, folies, enveloppen, tape) met typische gewichten en
materialen, kopieerbaar naar de eigen catalogus.

**Acceptance:** gebruiker vult een catalogus van 20 componenten in
< 15 min zonder zelf te wegen; bibliotheekwaarden dragen bron
"bibliotheek — indicatief".

**Priority:** must-have

**Notes:** startset ~25–30 items in MVP; dé onboarding-versneller.
Uitbreiden op basis van supportvragen.

### F-03 — SKU-register met effective-dated koppeling

**Description:** SKU ↔ verpakkingsconfiguratie (set componenten),
met geldigheidsperiode per koppeling.

**Acceptance:** verpakking wijzigen per datum splitst de
volumeberekening correct over beide configuraties; historische
koppelingen blijven opvraagbaar.

**Priority:** must-have

**Notes:** één SKU kan meerdere configuraties naast elkaar hebben
(bijv. seizoensverpakking) — dan verdeelsleutel per configuratie.

### F-04 — Verpakkingstype-classificatie

**Description:** elke configuratie is geclassificeerd als primair,
secundair, tertiair of verzendverpakking.

**Acceptance:** exports splitsen volumes volgens de classificatie
waar het koepel-formaat dat vereist.

**Priority:** must-have

**Notes:** verzendverpakking los van productverpakking modelleren;
multi-item orders delen één verzendverpakking (verdeelregel: O-05).

### F-05 — CSV-import

**Description:** import van SKU-lijsten en ordervolumes
(SKU × bestemmingsland × periode × aantal) via CSV met
kolom-mapping.

**Acceptance:** voorbeeldbestand beschikbaar; foutieve rijen worden
gerapporteerd zonder de import te blokkeren; herimport van dezelfde
periode vervangt idempotent.

**Priority:** must-have

**Notes:** CSV is de universele fallback en komt vóór de
platform-connectoren.

### F-06 — Platform-connectoren

**Description:** ophalen van SKU's en ordervolumes per
bestemmingsland uit WooCommerce, Shopify, Lightspeed en Bol.

**Acceptance:** connector haalt aggregaten op zonder klant-PII op te
slaan (N-03); mapping onbekende SKU's → werklijst.

**Priority:** should-have

**Notes:** volgorde op basis van validatiegesprekken; achter het
PlatformConnector-contract (Decision 0002).

### F-07 — Volumeberekeningsengine

**Description:** volumes × configuraties → kg per materiaal per land
per rapportageperiode.

**Acceptance:** pure functies, deterministisch; zelfde input +
regelversie ⇒ bit-identieke output; property-based tests op
splitsingen (F-03) en verdeelsleutels.

**Priority:** must-have

**Notes:** gewichten integer grammen (N-05); afronding pas in de
SchemeAdapter, nooit in de engine.

### F-08 — Scheme-export Verpact (NL)

**Description:** aangifte-export in het door Verpact vereiste formaat
en categorie-indeling.

**Acceptance:** valideert 0-afwijkend tegen golden files uit de
officiële veldspecs; drempel-/vrijstellingslogica correct toegepast.

**Priority:** must-have

### F-09 — Scheme-export LUCID/VerpackG (DE)

**Description:** export voor Duitse Systembeteiligung, incl. de door
LUCID vereiste materiaalindeling.

**Acceptance:** idem F-08; registratienummer-veld (LUCID-nr.)
verplicht in tenant-profiel.

**Priority:** must-have

**Notes:** DE = strengste handhaving; marketplaces checken LUCID-nr.

### F-10 — Scheme-export Fost Plus (BE)

**Description:** export in Fost Plus-formaat.

**Acceptance:** idem F-08.

**Priority:** should-have

### F-11 — Scheme-export CITEO (FR)

**Description:** export in CITEO-formaat.

**Acceptance:** idem F-08.

**Priority:** should-have

### F-12 — Verplichtingenmatrix + gratis scan

**Description:** matrix land × rol → verplichting + deadline +
status per tenant; publieke light-versie ("Is jouw webshop
PPWR-proof?") als leadmagnet achter e-mailveld.

**Acceptance:** ingelogde matrix toont status per verplichting;
publieke scan werkt zonder account en levert e-mailadressen.

**Priority:** must-have

**Notes:** zelfde module, twee gezichten; content gedreven door
dezelfde versioned regels als de checklist.

### F-13 — Audit trail

**Description:** mutatielog (wie, wat, wanneer, oude → nieuwe waarde)
op catalogus, koppelingen, volumes en tenant-profiel.

**Acceptance:** elke compliance-relevante mutatie is terug te vinden;
log is append-only.

**Priority:** must-have

### F-14 — Rapport-snapshot en immutability

**Description:** een gegenereerd/ingediend rapport bevriest alle
inputs (volumes, configuraties, regelversies, mappings) als snapshot.

**Acceptance:** rapport her-renderen vanaf snapshot is bit-identiek,
ook nadat brondata is gewijzigd (Decision 0004).

**Priority:** must-have

### F-15 — Accounts, abonnementen en tiers

**Description:** registratie, login, abonnementbeheer. Tiers:
Community €0 (self-host, AGPL) · Starter €29 (1 land, 100 SKU's) ·
Groei €79 (3 landen) · Pro €199 (onbeperkt, straks multi-tenant);
jaarplan met 2 maanden korting.

**Acceptance:** betaalflow via PSP werkt; tier-limieten worden
afgedwongen; jaarplan prominent aangeboden (churn-mitigatie: gebruik
piekt rond aangiftes).

**Priority:** must-have

**Notes:** PSP-keuze: O-14. Pay-per-aangifte bewust niet —
kannibaliseert het abonnement. Prijs value-based, niet cost-plus.

### F-16 — Multi-tenant voor fulfilmentcenters

**Description:** één organisatie beheert n klant-tenants met
rollen/rechten.

**Priority:** nice-to-have *(golf 2)*

### F-17 — DoC-generator + technisch dossier

**Description:** Declaration of Conformity (PDF) + technisch dossier
(ZIP) per verpakkingstype, met bewaararchief.

**Priority:** nice-to-have *(golf 2; inhoudseisen: O-07)*

### F-18 — Deadline-notificaties

**Description:** e-mailherinneringen voor aangifte- en
registratiedeadlines per land.

**Priority:** nice-to-have

### F-19 — Verpakkingsdashboard

**Description:** visueel inzicht: kg per materiaal en land over tijd,
recycled-content %, top-SKU's op verpakkingsgewicht, jaar-op-jaar.

**Acceptance:** MVP = één overzichtspagina op live data; grafieken
renderen < 1 s bij 5.000 SKU's.

**Priority:** should-have

**Notes:** golf 2: deelbaar duurzaamheidsoverzicht (link/PDF) voor
eindklanten van de webshop, en peer-benchmark (bouwt op F-20;
k-anonimiteit O-17). Eco-modulatie-kostenpreview zodra tarieflogica
stabiel is.

### F-20 — Carrier-dimensie in volumes

**Description:** VolumeRecord uitgebreid met optionele
carrier-dimensie (carrier × land × periode × aantal), gevuld waar de
bron dit kent.

**Acceptance:** aggregaten blijven PII-vrij (N-03); carrier-mix
zichtbaar in het dashboard; expliciet benoemd in de privacyverklaring
(Decision 0010).

**Priority:** should-have

**Notes:** voedt de peer-benchmark en PakketRadar-marktintel
(niveau 1). Niveau 2 (tracking-events, opt-in) is out of scope —
golf 2, eigen juridisch traject.

---

## Non-functional requirements

### N-01 — Correctheid

- Golden-file testset per koepel per rapportagejaar; CI blokkeert bij
  elke afwijking
- Berekeningsengine: pure functies, property-based tests

### N-02 — Temporele integriteit

- Alle regels, tarieven, mappings en koppelingen effective-dated
  (Decision 0003)
- Rapport over jaar X blijft in jaar X+n reproduceerbaar met de
  regels van jaar X

### N-03 — Privacy & dataminimalisatie

- Alleen geaggregeerde volumes (SKU × land × periode); geen
  ordernummers, geen klant-PII (Decision 0006)
- EU-hosting; verwerkersovereenkomst-proof
- Strikte tenant-isolatie op query-niveau

### N-04 — Security

- HTTPS + HSTS; secrets in vault, nooit in code of logs
- Auth: gevestigde library/provider, geen eigen crypto; 2FA optioneel
- Dependencies wekelijks gescand

### N-05 — Eenheden & afronding

- Gewichten opgeslagen als integer grammen
- Afronding per koepel-formaat gedefinieerd in de SchemeAdapter,
  nergens anders

### N-06 — Beschikbaarheid

- 99,5% uptime; capaciteitspiek rond aangiftedeadlines (Q1)
- Geen realtime-vereisten

### N-07 — Performance

- Export genereren < 30 s bij 5.000 SKU's
- UI-interacties < 200 ms p95

### N-08 — Onderhoudbaarheid van de moat

- Nieuwe koepel toevoegen = alleen nieuwe SchemeAdapter + golden
  files, geen core-wijziging (Decision 0002)
- Jaarlijkse formaatwijziging per koepel doorvoeren ≤ 1 dag

---

## Constraints

- **Regulatorisch:** PPWR van toepassing per 12 aug 2026;
  koepel-formaten worden extern bepaald en wijzigen jaarlijks
- **AVG/GDPR:** data blijft in de EU
- **Timeline:** MVP live vóór 12 aug 2026; bouwsprint max 3–4 weken
  naast de PakketRadar Black Friday-voorbereiding
- **Capaciteit:** één ontwikkelaar (solo)
- **Budget:** infra near-zero (homelab Swarm) tot tractie
- **Aansprakelijkheid:** geen juridisch advies; alle output
  "ter controle door gebruiker", verankerd in voorwaarden
- **Licentie:** AGPL-3.0 vanaf launch — alle servercode publiek
  (Decision 0008)

---

## Out of scope

- Juridisch advies of compliance-garanties
- Directe (API-)indiening bij koepels — export is een bestand
- Labelling-generator en recyclability-grading (delegated acts open)
- Eco-modulatie fee-calculator (tot tarieflogica stabiel is)
- Landen buiten NL/DE/BE/FR
- Native apps; realtime features
- Verpakkingsontwerp-advies (welke doos moet ik kiezen)
- Opt-in tracking-datamodule voor PakketRadar (niveau 2,
  Decision 0010) — golf 2, eigen juridisch traject
- Support-SLA voor self-hosters (best effort via issues)

---

## Open questions

Regulatorisch — dit onderzoek ís het product; antwoorden gaan naar de
Log, keuzes naar Decisions:

- [ ] O-01 Exacte veldspecs per koepel: Verpact-aangifte,
      LUCID-datamodel + Systembeteiligung, Fost Plus, CITEO —
      categorieën, eenheden, afronding
- [ ] O-02 Drempels en vereenvoudigde aangifte per land (NL ±50.000
      kg-grens verifiëren; DE geen drempel; BE/FR?)
- [ ] O-03 Welke PPWR-verplichtingen gelden per 12 aug 2026 vs later
      (labelling, recycled content, leegruimte-ratio)?
- [ ] O-04 Serviceverpakkingen-regeling NL: wie rapporteert wat?
- [ ] O-05 Retouren aftrekbaar? B2B vs B2C? Marketplace/FBA: wie is
      producer? Verdeelregel verzendverpakking bij multi-item orders
- [ ] O-06 Authorised Representative-eisen per land voor sellers
      zonder vestiging
- [ ] O-07 DoC/technisch dossier: exacte inhoud (Annex VII PPWR) +
      bewaartermijn
- [ ] O-08 Recyclability-grading delegated act: welke data nú al
      vastleggen om straks grades te kunnen berekenen?
- [ ] O-09 Hebben koepels indien-API's of alleen portalen?

Markt:

- [ ] O-10 Betalingsbereidheid uit de 10–15 validatiegesprekken
- [ ] O-11 Doet de webshop aangifte zelf of via accountant? →
      bepaalt export-vorm én wie de user is
- [ ] O-12 Waar zit hun data nu (leveranciersmails, spreadsheets)? →
      bepaalt import-UX

Technisch:

- [ ] O-14 PSP: Mollie vs Stripe (NL-focus → Mollie waarschijnlijk)
- [ ] O-15 Bestaat een bruikbare standaard-materiaaltaxonomie als
      basis voor de catalogus?
- [ ] O-16 Naam/merk "DoosDossier" vastleggen (handelsnaam +
      BOIP-merkregistratie) vóór de repo publiek gaat
- [ ] O-17 K-anonimiteitsdrempel voor de peer-benchmark (minimale
      groepsgrootte per segment)

---

## Glossary

| Term                  | Meaning                                                        |
|-----------------------|----------------------------------------------------------------|
| *PPWR*                | Packaging and Packaging Waste Regulation (EU), van toepassing 12-08-2026 |
| *EPR*                 | Extended Producer Responsibility — producentenverantwoordelijkheid per land |
| *Koepel*              | Nationale EPR-organisatie (PRO): Verpact, LUCID/VerpackG, Fost Plus, CITEO |
| *Producer*            | Partij die verpakking in een lidstaat op de markt brengt — cross-border webshop is dit per bestemmingsland |
| *Systembeteiligung*   | Duitse plicht tot deelname aan een duaal systeem (VerpackG)    |
| *AR*                  | Authorised Representative — lokale vertegenwoordiger voor sellers zonder vestiging |
| *DoC*                 | Declaration of Conformity                                      |
| *Serviceverpakking*   | Verpakking gevuld op verkooppunt; NL kent afwijkende regeling  |
| *Primair/secundair/tertiair* | Wettelijke verpakkingsniveaus: product-, bundel-, transportverpakking |
| *Configuratie*        | Set componenten die samen één verpakking van een SKU vormen    |
| *VolumeRecord*        | Aggregaat: SKU × bestemmingsland × periode × aantal            |
| *SchemeAdapter*       | Output-adapter per koepel: validate / transform / render       |
| *PlatformConnector*   | Input-adapter per shopplatform                                 |
| *Golden file*         | Vastgelegde referentie-output waar exports bit-exact aan moeten voldoen |
| *Effective dating*    | Elke regel/koppeling heeft een geldigheidsperiode              |

---

*Once implementation begins, individual requirements typically get
mirrored into the issue tracker for working state. The Spec stays as
the canonical reference; the tracker handles "what is being done now".*

*If a requirement evolves significantly mid-project, update it here
and note the change in the Log. Major reframings warrant a Decision.*
