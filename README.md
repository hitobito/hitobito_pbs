# Hitobito PBS

This hitobito wagon defines the organization hierarchy with groups and roles of Pfadibewegung Schweiz.

# Pfadi Organization Hierarchy

<!-- roles:start -->
    * Root
      * Root
        * Admin: 2FA [:layer_and_below_full]
    * Bund
      * Bund
        * Mitarbeiter*in GS: 2FA [:layer_and_below_full, :contact_data, :admin]
        * IT Support: 2FA [:layer_and_below_full, :contact_data, :admin, :impersonation]
        * Sekretariat: 2FA [:layer_and_below_full, :contact_data]
        * Adressverwalter*in: 2FA [:layer_and_below_full]
        * PowerUser: 2FA [:layer_and_below_full]
        * Assistenz Ausbildung: [:layer_full]
        * Präsident*in: [:group_read, :contact_data]
        * Vize Präsident*in: [:group_read, :contact_data]
        * Präsident*in APV: [:group_read]
        * Geschäftsleiter*in: 2FA [:layer_and_below_read, :contact_data, :approve_applications]
        * Mitarbeiter*in: [:group_read, :contact_data]
        * Vertreter*in PBS: [:group_read, :contact_data]
        * Beisitzer*in: [:group_read]
        * Kassier*in: 2FA [:layer_and_below_read, :contact_data]
        * Rechnungen: 2FA [:layer_and_below_read, :finance, :contact_data]
        * Revisor*in: [:group_read, :contact_data]
        * Redaktor*in: 2FA [:layer_and_below_read, :contact_data]
        * Webmaster: [:group_read, :contact_data]
        * Mediensprecher*in: 2FA [:layer_and_below_read, :contact_data]
        * Übersetzer*in: [:group_read, :contact_data]
        * Mitglied Krisenteam: 2FA [:layer_and_below_read, :contact_data, :crisis_trigger]
        * Coach: 2FA [:layer_and_below_read, :contact_data]
        * Grossanlass Coach: 2FA [:layer_and_below_read, :contact_data]
        * Leiterkursbetreuer*in: [:group_read, :contact_data]
        * Leiter*in Kernaufgabe Ausbildung: [:layer_full, :group_read, :contact_data, :approve_applications]
        * Leiter*in Kernaufgabe Kommunikation: [:group_read, :crisis_trigger]
        * Leiter*in Kernaufgabe Programm: [:group_read, :contact_data]
        * Leiter*in Kernaufgabe Support: [:group_read, :contact_data]
        * Verantwortlicher Biberstufe: [:group_read, :contact_data]
        * Verantwortliche*r Wolfstufe: [:group_read, :contact_data]
        * Verantwortliche*r Pfadistufe: [:group_read, :contact_data]
        * Verantwortliche*r Piostufe: [:group_read, :contact_data]
        * Verantwortliche*r Roverstufe: [:group_read, :contact_data]
        * Verantwortliche*r Pfadi Trotz Allem: [:group_read, :contact_data]
        * Verantwortliche*r Diversität und Inklusion: [:group_read, :contact_data]
        * Verantwortliche*r Lagermeldung: [:group_read, :contact_data]
        * Verantwortliche*r PR: [:group_read, :contact_data]
        * Verantwortliche*r Prävention: [:group_read, :contact_data]
        * Verantwortliche*r Krisenteam: [:group_read, :contact_data, :crisis_trigger]
        * International Commissioner IC WAGGGS: [:group_read, :contact_data]
        * International Commissioner IC WOSM: [:group_read, :contact_data]
        * Stv IC Programme WAGGGS: [:group_read, :contact_data]
        * Stv IC Programme WOSM: [:group_read, :contact_data]
        * Spezialfunktion: [:group_read]
        * Ehrenmitglied: []
        * Passivmitglied: []
        * Kontaktperson: [:contact_data]
        * Selbstregistrierte*r: []
      * Ausbildungskommission
        * Mitglied: [:group_read, :contact_data]
      * Gremium
        * Leiter*in: [:group_and_below_full]
        * Mitglied: [:group_read]
      * Kommission
        * Leiter*in: [:layer_read, :group_and_below_full]
        * Mitglied: [:layer_read]
    * Kantonalverband
      * Kantonalverband
        * Kantonsleiter*in: 2FA [:layer_and_below_full, :contact_data, :approve_applications]
        * Sekretariat: 2FA [:layer_and_below_full, :contact_data]
        * Adressverwalter*in: 2FA [:layer_and_below_full]
        * PowerUser: 2FA [:layer_and_below_full]
        * Präsident*in: [:group_read, :contact_data]
        * Vize Präsident*in: [:group_read, :contact_data]
        * Präsident*in APV: [:group_read]
        * Mitarbeiter: [:group_read, :contact_data]
        * Beisitzer*in: [:group_read]
        * Kassier*in: 2FA [:layer_and_below_read, :contact_data]
        * Rechnungen: 2FA [:layer_and_below_read, :finance, :contact_data]
        * Revisor*in: [:group_read, :contact_data]
        * Redaktor*in: 2FA [:layer_and_below_read, :contact_data]
        * Webmaster: [:group_read, :contact_data]
        * Mediensprecher*in: 2FA [:layer_and_below_read, :contact_data]
        * Übersetzer*in: [:group_read, :contact_data]
        * Mitglied Krisenteam: 2FA [:layer_and_below_read, :contact_data, :crisis_trigger]
        * Coach: 2FA [:layer_and_below_read, :contact_data]
        * Leiterkursbetreuer*in: 2FA [:layer_and_below_read, :contact_data]
        * Verantwortliche*r Biberstufe: [:group_read, :contact_data]
        * Verantwortliche*r Wolfstufe: [:group_read, :contact_data]
        * Verantwortliche*r Pfadistufe: [:group_read, :contact_data]
        * Verantwortliche*r Piostufe: [:group_read, :contact_data]
        * Verantwortliche*r Roverstufe: [:group_read, :contact_data]
        * Verantwortliche*r Pfadi Trotz Allem: [:group_read, :contact_data]
        * Verantwortliche*r Abteilungen: [:group_read, :contact_data]
        * Verantwortliche*r Animation Spirituelle: [:group_read, :contact_data]
        * Verantwortliche*r Ausbildung: 2FA [:layer_full, :layer_and_below_read, :contact_data, :approve_applications]
        * Verantwortliche*r Betreuung: 2FA [:layer_and_below_read, :contact_data]
        * Verantwortliche*r Diversität und Inklusion: [:group_read, :contact_data]
        * Verantwortliche*r Internationales: [:group_read, :contact_data]
        * Verantwortliche*r kantonales Suchtpräventionsprogramm: [:group_read, :contact_data]
        * Verantwortliche*r Kantonsarchiv: [:group_read, :contact_data]
        * Verantwortliche*r Krisenteam: 2FA [:layer_and_below_read, :contact_data, :crisis_trigger]
        * Verantwortliche*r Lagermeldung: 2FA [:layer_and_below_read, :contact_data]
        * Verantwortliche*r Lagerplätze: [:group_read, :contact_data]
        * Verantwortliche*r Materialverkaufsstelle: [:group_read, :contact_data]
        * Verantwortliche*r PR: [:group_read, :contact_data]
        * Verantwortliche*r Prävention: [:group_read, :contact_data]
        * Verantwortliche*r Programm: [:group_read, :contact_data]
        * Verantwortliche*r Nachhaltigkeit und Umwelt: [:group_read, :contact_data]
        * Spezialfunktion: [:group_read]
        * Ehrenmitglied: []
        * Passivmitglied: []
        * Selbstregistrierte*r: []
      * Gremium
        * Leiter*in: [:group_and_below_full]
        * Mitglied: [:group_read]
        * Selbstregistrierte*r: []
      * Internes Gremium
        * Leitung: [:group_and_below_full]
        * Mitglied: [:group_read]
      * Kommission
        * Leiter*in: [:group_and_below_full, :layer_and_below_read]
        * Mitglied: [:layer_and_below_read]
    * Region
      * Region
        * Regionsleiter*in: 2FA [:layer_and_below_full, :contact_data, :approve_applications]
        * Sekretariat: 2FA [:layer_and_below_full, :contact_data]
        * Adressverwalter*in: 2FA [:layer_and_below_full]
        * PowerUser: 2FA [:layer_and_below_full]
        * Präsident*in: [:group_read, :contact_data]
        * Vize Präsident*in: [:group_read, :contact_data]
        * Präsident*in APV: [:group_read]
        * Präses: [:group_read, :contact_data]
        * Mitarbeiter*in: [:group_read, :contact_data]
        * Beisitzer*in: [:group_read]
        * Kassier*in: 2FA [:layer_and_below_read, :contact_data]
        * Rechnungen: 2FA [:layer_and_below_read, :finance, :contact_data]
        * Revisor: [:group_read, :contact_data]
        * Redaktor*in: 2FA [:layer_and_below_read, :contact_data]
        * Webmaster: [:group_read, :contact_data]
        * Mediensprecher*in: 2FA [:layer_and_below_read, :contact_data]
        * Mitglied Krisenteam: 2FA [:layer_and_below_read, :contact_data]
        * Coach: 2FA [:layer_and_below_read, :contact_data]
        * Leiterkursbetreuer*in: 2FA [:layer_and_below_read, :contact_data]
        * Verantwortliche*r Biberstufe: [:group_read, :contact_data]
        * Verantwortliche*r Wolfstufe: [:group_read, :contact_data]
        * Verantwortliche*r Pfadistufe: [:group_read, :contact_data]
        * Verantwortliche*r Piostufe: [:group_read, :contact_data]
        * Verantwortliche*r Roverstufe: [:group_read, :contact_data]
        * Verantwortliche*r Pfadi Trotz Allem: [:group_read, :contact_data]
        * Verantwortliche*r Abteilungen: [:group_read, :contact_data]
        * Verantwortliche*r Animation Spirituelle: [:group_read, :contact_data]
        * Verantwortliche*r Ausbildung: 2FA [:layer_full, :layer_and_below_read, :contact_data, :approve_applications]
        * Verantwortliche*r Betreuung: 2FA [:layer_and_below_read, :contact_data]
        * Verantwortliche*r Diversität und Inklusion: [:group_read, :contact_data]
        * Verantwortliche*r Internationales: [:group_read, :contact_data]
        * Verantwortliche*r kantonales Suchtpräventionsprogramm: [:group_read, :contact_data]
        * Verantwortliche*r Krisenteam: 2FA [:layer_and_below_read, :contact_data]
        * Verantwortliche*r Lagermeldung: 2FA [:layer_and_below_read, :contact_data]
        * Verantwortliche*r Lagerplätze: [:group_read, :contact_data]
        * Verantwortliche*r Materialverkaufsstelle: [:group_read, :contact_data]
        * Verantwortliche*r PR: [:group_read, :contact_data]
        * Verantwortliche*r Prävention: [:group_read, :contact_data]
        * Verantwortliche*r Programm: [:group_read, :contact_data]
        * Spezialfunktion: [:group_read]
        * Ehrenmitglied: []
        * Passivmitglied: []
        * Selbstregistrierte*r: []
      * Rover
        * Einheitsleiter*in: [:layer_and_below_read]
        * Mitleiter*in: [:layer_and_below_read]
        * Adressverwalter*in: [:group_and_below_full]
        * Rover: []
      * Gremium
        * Leiter*in: [:group_and_below_full]
        * Mitglied: [:group_read]
      * Internes Gremium
        * Leitung: [:group_and_below_full]
        * Mitglied: [:group_read]
      * Kommission
        * Leiter*in: [:group_and_below_full, :layer_and_below_read]
        * Mitglied: [:layer_and_below_read]
    * Abteilung
      * Abteilung
        * Abteilungsleiter*in: [:layer_and_below_full, :contact_data, :approve_applications]
        * Abteilungsleiter*in Stv: [:layer_and_below_full, :contact_data, :approve_applications]
        * Sekretariat: [:layer_and_below_full, :contact_data]
        * Adressverwalter*in: [:layer_full]
        * PowerUser: [:layer_full]
        * Präsident*in: [:group_read, :contact_data]
        * Vize Präsident*in: [:group_read, :contact_data]
        * Präsident*in APV: [:group_read]
        * Präsident*in Elternrat: [:group_read]
        * Präses: [:group_read]
        * Beisitzer*in: [:group_read]
        * Materialwart*in: [:group_read]
        * Heimverwalter*in: [:group_read, :contact_data]
        * Stufenleiter*in Biber: [:layer_and_below_read]
        * Stufenleiter*in Wölfe: [:layer_and_below_read]
        * Stufenleiter*in Pfadi: [:layer_and_below_read]
        * Stufenleiter*in Pio: [:layer_and_below_read]
        * Stufenleiter*in Rover: [:layer_and_below_read]
        * Stufenleiter*in PTA: [:layer_and_below_read]
        * Kassier*in: [:layer_and_below_read, :contact_data]
        * Rechnungen: [:layer_and_below_read, :finance, :contact_data]
        * Revisor*in: [:group_read, :contact_data]
        * Redaktor*in: [:layer_and_below_read, :contact_data]
        * Webmaster: [:group_read, :contact_data]
        * Coach: [:layer_and_below_read, :contact_data]
        * Verantwortliche*r Materialverkaufsstelle: [:group_read, :contact_data]
        * Verantwortliche*r Pfadi Trotz Allem: [:group_read, :contact_data]
        * Verantwortliche*r PR: [:group_read, :contact_data]
        * Spezialfunktion: [:group_read]
        * Ehrenmitglied: []
        * Passivmitglied: []
        * Selbstregistrierte*r: []
      * Biber
        * Einheitsleiter*in: [:layer_and_below_read]
        * Mitleiter*in: [:layer_and_below_read]
        * Adressverwalter*in: [:group_and_below_full]
        * Biber: []
      * Wölfe
        * Einheitsleiter*in: [:layer_and_below_read]
        * Mitleiter*in: [:layer_and_below_read]
        * Adressverwalter*in: [:group_and_below_full]
        * Leitwolf: []
        * Wolf: []
      * Pfadi
        * Einheitsleiter*in: [:layer_and_below_read]
        * Mitleiter*in: [:layer_and_below_read]
        * Adressverwalter*in: [:group_and_below_full]
        * Leitpfadi: [:group_read]
        * Pfadi: []
      * Pio
        * Einheitsleiter*in: [:layer_and_below_read]
        * Mitleiter*in: [:layer_and_below_read]
        * Adressverwalter*in: [:group_and_below_full]
        * Pio: []
      * Rover
        * Einheitsleiter*in: [:layer_and_below_read]
        * Mitleiter*in: [:layer_and_below_read]
        * Adressverwalter*in: [:group_and_below_full]
        * Rover: []
      * PTA
        * Einheitsleiter*in: [:layer_and_below_read]
        * Mitleiter*in: [:layer_and_below_read]
        * Adressverwalter*in: [:group_and_below_full]
        * Mitglied: []
      * Elternrat
        * Präsident*in: [:group_full]
        * Mitglied: [:group_read]
        * Selbstregistrierte*r: []
      * Gremium
        * Leiter*in: [:group_and_below_full]
        * Mitglied: [:group_read]
        * Selbstregistrierte*r: []
      * Internes Gremium
        * Leitung: [:group_and_below_full]
        * Mitglied: [:group_read]
    * Silverscouts
      * Silverscouts
        * Leitung: [:group_read, :contact_data]
        * Mitglied: []
    * Global
      * Ehemalige
        * Mitglied: []
        * Leitung: [:group_full]

(Output of rake app:hitobito:roles)
<!-- roles:end -->
