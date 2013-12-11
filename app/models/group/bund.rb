# encoding: utf-8
class Group::Bund < Group

  self.layer = true

  children Group::Kantonalverband

  class Adressverwaltung < ::Role
    self.permissions = [:layer_full]
  end

  class Beisitz < ::Role
    self.permissions = [:group_read]
  end

  class Coach < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  class Ehrenmitglied < ::Role
    self.permissions = []
    self.affiliate = true
  end

  class Geschaeftsleitung < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  class GrossanlassCoach < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class InternationalCommissionerIcWagggs < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class InternationalCommissionerIcWosm < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Kassier < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  class Kontaktperson < ::Role
    self.permissions = [:contact_data]
    self.affiliate = true
  end

  class Leitungskursbetreuung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class LeitungKernaufgabeAusbildung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class LeitungKernaufgabeKommunikation < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class LeitungKernaufgabeProgramm < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class LeitungKernaufgabeSupport < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Mediensprecher < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Mitarbeiter < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class MitarbeiterGs < ::Role
    self.permissions = [:layer_full, :contact_data, :admin]
  end

  class MitgliedKrisenteam < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Passivmitglied < ::Role
    self.permissions = []
    self.affiliate = true
  end

  class Praesidium < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class PraesidiumApv < ::Role
    self.permissions = [:group_read]
  end

  class Redaktor < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  class Revisor < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Sekretariat < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class Spezialfunktion < ::Role
    self.permissions = [:group_read]
  end

  class StvIcProgrammeWagggs < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class StvIcProgrammeWosm < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Uebersetzer < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungBiberstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungIntegration < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungLagermeldung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPfadiTrotzAllem < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPfadistufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPiostufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPr < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPraeventionSexuellerAusbeutung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungRoverstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungWolfstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VertretungPbs < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VizePraesidium < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Webmaster < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  roles MitarbeiterGs,
        Sekretariat,
        Adressverwaltung,
        Praesidium,
        VizePraesidium,
        PraesidiumApv,
        Geschaeftsleitung,
        Mitarbeiter,
        VertretungPbs,
        Beisitz,

        Kassier,
        Revisor,
        Redaktor,
        Webmaster,
        Mediensprecher,
        Uebersetzer,
        MitgliedKrisenteam,

        Coach,
        GrossanlassCoach,
        Leitungskursbetreuung,

        LeitungKernaufgabeAusbildung,
        LeitungKernaufgabeKommunikation,
        LeitungKernaufgabeProgramm,
        LeitungKernaufgabeSupport,

        VerantwortungBiberstufe,
        VerantwortungWolfstufe,
        VerantwortungPfadistufe,
        VerantwortungPiostufe,
        VerantwortungRoverstufe,
        VerantwortungPfadiTrotzAllem,
        VerantwortungIntegration,
        VerantwortungLagermeldung,
        VerantwortungPr,
        VerantwortungPraeventionSexuellerAusbeutung,

        InternationalCommissionerIcWagggs,
        InternationalCommissionerIcWosm,
        StvIcProgrammeWagggs,
        StvIcProgrammeWosm,

        Spezialfunktion,

        Ehrenmitglied,
        Passivmitglied,
        Kontaktperson

end
