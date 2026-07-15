# Decision 0008: AGPL-3.0 open source vanaf launch

**Status:**      Accepted
**Date:**        2026-07-13
**Supersedes:**  [Decision 0007](./0007-closed-source-tot-na-deadline-golf.md)

## Context

Decision 0007 hield DoosDossier dicht om de moat (koepel-formaten,
rapportlogica) te beschermen. Nieuw inzicht: open source als
acquisitiekanaal ("gratis als je zelf host") en community-signaal
weegt zwaarder, mits het fork-risico juridisch wordt afgedekt en de
framing transparant is — de OSS-doelgroep straft sneaky kleine
lettertjes af.

## Decision

De volledige applicatie gaat bij launch publiek onder AGPL-3.0;
gratis = self-host, betaald = hosted + jaarlijks bijgehouden
koepel-formaten, hosted platform-connectoren (onze OAuth-apps),
defaults-bibliotheek-data en (later) multi-tenant.

## Considerations

**Pro:** AGPL dwingt SaaS-forks tot volledige openheid — dat neemt
het kern-bezwaar uit 0007 weg; credibility/Tweakers-effect zoals bij
PakketRadar; self-hosters worden ambassadeurs richting de betaalde
laag.
**Con:** community-supportlast tijdens de sprint (mitigatie:
expliciete no-SLA); formaat-kennis wordt leesbaar voor concurrenten —
maar bijhouden ervan blijft de eigenlijke moat.

Verworpen: closed (0007 — verliest momentum en community); MIT/Apache
(SaaS-klonen vrij spel); open core (grens loopt dwars door de
rapportlogica).

## Consequences

- LICENSE = AGPL-3.0; trademark/handelsnaam vastleggen vóór publicatie
  (O-16)
- Pricing-pagina communiceert self-host-optie expliciet, niet verstopt
- Heroverwegingsmoment uit 0007 vervalt

---

*Keep Decisions under roughly one screen. Do not edit the Decision
once accepted — write a superseding Decision instead.*
