# encoding: utf-8
class Group::Bund < Group

  self.layer = true

  children Group::Kantonalverband

  class Adressverwalter < ::Role
    self.permissions = [:layer_full]
  end

  class Beisitzer < ::Role
    self.permissions = [:group_read]
  end

  class Coach < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  class Ehrenmitglied < ::Role
    self.permissions = []
    self.affiliate = true
  end

  class Geschaeftsleiter < ::Role
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

  class Leiterkursbetreuer < ::Role
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
    self.permissions = [:layer_full, :contact_data]
  end

  class MitgliedKrisenteam < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Passivmitglied < ::Role
    self.permissions = []
    self.affiliate = true
  end

  class Praesident < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class PraesidentApv < ::Role
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

  class VerantwortlicherBiberstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherIntegration < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherLagermeldung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherPfadiTrotzAllem < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherPfadistufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherPiostufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherPr < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherPraeventionSexuellerAusbeutung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherRoverstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherWolfstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VertreterPbs < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VizePraesident < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Webmaster < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  roles MitarbeiterGs,
        Sekretariat,
        Adressverwalter,
        Praesident,
        VizePraesident,
        PraesidentApv,
        Geschaeftsleiter,
        Mitarbeiter,
        VertreterPbs,
        Beisitzer,

        Kassier,
        Revisor,
        Redaktor,
        Webmaster,
        Mediensprecher,
        Uebersetzer,
        MitgliedKrisenteam,

        Coach,
        GrossanlassCoach,
        Leiterkursbetreuer,

        LeitungKernaufgabeAusbildung,
        LeitungKernaufgabeKommunikation,
        LeitungKernaufgabeProgramm,
        LeitungKernaufgabeSupport,

        VerantwortlicherBiberstufe,
        VerantwortlicherWolfstufe,
        VerantwortlicherPfadistufe,
        VerantwortlicherPiostufe,
        VerantwortlicherRoverstufe,
        VerantwortlicherPfadiTrotzAllem,
        VerantwortlicherIntegration,
        VerantwortlicherLagermeldung,
        VerantwortlicherPr,
        VerantwortlicherPraeventionSexuellerAusbeutung,

        InternationalCommissionerIcWagggs,
        InternationalCommissionerIcWosm,
        StvIcProgrammeWagggs,
        StvIcProgrammeWosm,

        Spezialfunktion,

        Ehrenmitglied,
        Passivmitglied,
        Kontaktperson

end
