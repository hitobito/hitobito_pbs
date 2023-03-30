# Hitobito PBS Changelog

## unreleased

*   Das Anwesenheiten-Tab bei Kursen im Status "Qualifikationen erfasst" und "Abgeschlossen" wird neu mit einem Ausrufezeichen markiert, wenn die Anwesenheiten noch gespeichert werden müssen. Merci @ewangler! (hitobito/hitobito_pbs#262)
*   Adressverwalter\*innen auf der Abteilungsebene können neu auch für Zugriffsanfragen ausgewählt werden. Merci @philobr! (hitobito/hitobito_pbs#261)

## Version 1.28

*   Bei J+S Kursen/Lager müssen Teilnehmer bei Anmeldung der Datenweitergabe zustimmen (hitobito_pbs#1956)

## Version 1.28

*   Referent*innen eines Kurses werden neu nach Abschluss des Kurses im Tab "Qualifikationen" angezeigt. Dort können ihnen dann die Qualifikation ausgestellt werden (hitobito_pbs#233)
*   Group Health Endpunkt enthält keine Internen Gremien mehr. Neu können auch Regionen und Kantonalverbände in den Group Health Check aufgenommen werden. Zusätzlich gibt es neu den Endpunkt `/group_health/census_evaluations` welcher die Gruppenstatistik für Group Health Gruppen ausgibt. Dafür muss das Service Token aber zusätzlich die Berechtigung Bestandesmeldung Export-Endpunkt besitzen. (hitobito_pbs#232)

## Version 1.27

*   Es können für Abos nur noch Mailadressen mit dem korrekten PBS-Kürzel vergeben werden (siehe https://pfadi.swiss/media/files/0e/betriebshandbuch_v32_20160223_de.pdf#page52R_mcid34 Seite 11, Kapitel 4.2, dritter Punkt).

## Version 1.26

*   Neue Rolle "Verantwortliche*r Nachhaltigkeit und Umwelt" auf dem Kantonalverband hinzugefügt

## Version 1.20

*   Lagerhierarchien hinzugefügt
*   weitere Anmeldeangaben standardmässig als verpflichtend gekennzeichnet.
*   JSON-Export von Lagern erweitert
*   Unterstützung für Pfadifinder hinzugefügt
*   Hilfeseite mit Links zu Leitfäden der PBS hinzugefügt
*   Kursbestätigungen als PDF herunterladen können


## Version 1.19

*   Erweiterterter BSV / LKB Export
*   Statistik auf Ebene Kantonalverband zeigt nun alle Abteilungen des Kantons an.


## Version 1.17

*   Bugfix: Kantonalverband wird wieder gesetzt


## Version 1.16

*   Neuer Gruppentyp Ausbildungskommission auf Ebene Bund.
*   Pro Ebene einstellbar, welche Rollen Benachrichtigungen für Kursempfehlungen erhalten.
*   Neuer Platzhalter für Mail-Texte um die gewählte Anrede zu verwenden.
*   Erfassungsmöglichkeit der BSV Anwesenheitstage für Kurse.
*   Neue Übersicht über alle Empfehlungsdaten für Kursleiter
*   Bereits freigebene Kursteilnehmer werden auf der Anzeige der Kursfreigaben weiterhin angezeigt.
*   Zugehörigkeit zur Abteilung wird auf den Teilnehmerlisten angezeigt
*   Reihenfolge der Kursliste korrigiert
*   Zugriffsberechtigungen von LKB angepasst
*   Neu strukturierte Empfehlungen für Kurse
*   Empfehlungsinstanz kann gewählt werden


## Version 1.15

*   Statistik und Bestandesmeldung mit Total pro Geschlecht
*   Rolle Materialwart und Heimverwaltung aktiviert
*   Bei Kursarten definierbar, ob ein Kurs ebenfalls als Lager angemeldet werden soll.
*   Suche nach PBS Personennummer möglich.


## Version 1.11

*   PBS Branding
*   Lagertage berechnen
*   Lagerleitung nur einer Person zuweisbar
*   Checkboxen für Lagerleitung
*   keine Kontaktperson auf Lager
*   Zusätzliche Validierungen beim Lager einreichen
*   Sichtbarkeit von Lagerfelder für Teilnehmer
*   CSV Export für Lager


## Version 1.10

*   Lagerverwaltung
