# encoding: utf-8
class Group::Kantonalverband < Group

  self.layer = true

  children Group::Region,
           Group::Abteilung

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

  class Kantonsleiter < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class Kassier < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  class Leiterkursbetreuer < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Mediensprecher < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Mitarbeiter < ::Role
    self.permissions = [:group_read, :contact_data]
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

  class Uebersetzer < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherAbteilungen < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherAnimationSpirituelle < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherAusbildung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherBetreuung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherBiberstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherIntegration < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherInternationales < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherSuchtpraeventionsprogramm < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherKantonsarchiv < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherKrisenteam < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherLagermeldung < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherLagerplaetze < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherMaterialverkaufsstelle < ::Role
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

  class VerantwortlicherProgramm < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherRoverstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherWolfstufe < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VizePraesident < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Webmaster < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  roles Kantonsleiter,
        Sekretariat,
        Adressverwalter,
        Praesident,
        VizePraesident,
        PraesidentApv,
        Mitarbeiter,
        Beisitzer,

        Kassier,
        Revisor,
        Redaktor,
        Webmaster,
        Mediensprecher,
        Uebersetzer,
        MitgliedKrisenteam,

        Coach,
        Leiterkursbetreuer,

        VerantwortlicherBiberstufe,
        VerantwortlicherWolfstufe,
        VerantwortlicherPfadistufe,
        VerantwortlicherPiostufe,
        VerantwortlicherRoverstufe,
        VerantwortlicherPfadiTrotzAllem,
        VerantwortlicherAbteilungen,
        VerantwortlicherAnimationSpirituelle,
        VerantwortlicherAusbildung,
        VerantwortlicherBetreuung,
        VerantwortlicherIntegration,
        VerantwortlicherInternationales,
        VerantwortlicherSuchtpraeventionsprogramm,
        VerantwortlicherKantonsarchiv,
        VerantwortlicherKrisenteam,
        VerantwortlicherLagermeldung,
        VerantwortlicherLagerplaetze,
        VerantwortlicherMaterialverkaufsstelle,
        VerantwortlicherPr,
        VerantwortlicherPraeventionSexuellerAusbeutung,
        VerantwortlicherProgramm,

        Spezialfunktion,

        Ehrenmitglied,
        Passivmitglied
end