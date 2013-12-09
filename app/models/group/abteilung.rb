# encoding: utf-8
class Group::Abteilung < Group

  self.layer = true

  children Group::Biber,
           Group::Woelfe,
           Group::Pfadi,
           Group::Pio,
           Group::Rover,
           Group::Pta,
           Group::Elternrat


  class Abteilungsleiter < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class AbteilungsleiterStv < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

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

  class Heimverwalter < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Kassier < ::Role
    self.permissions = [:layer_read, :contact_data]
  end

  class Materialwart < ::Role
    self.permissions = [:group_read]
  end

  class Passivmitglied < ::Role
    self.permissions = []
    self.affiliate = true
  end

  class Praeses < ::Role
    self.permissions = [:group_read]
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

  class StufenleiterBiber < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleiterWoelfe < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleiterPfadi < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleiterPio < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleiterRover < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleiterPta < ::Role
    self.permissions = [:layer_read]
  end

  class VerantwortlicherMaterialverkaufsstelle < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherPfadiTrotzAllem < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortlicherPr < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VizePraesident < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Webmaster < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  roles Abteilungsleiter,
        AbteilungsleiterStv,
        Sekretariat,
        Adressverwalter,
        Praesident,
        VizePraesident,
        PraesidentApv,
        Praeses,
        Beisitzer,

        StufenleiterBiber,
        StufenleiterWoelfe,
        StufenleiterPfadi,
        StufenleiterPio,
        StufenleiterRover,
        StufenleiterPta,

        Kassier,
        Revisor,
        Redaktor,
        Webmaster,
        Coach,

        VerantwortlicherMaterialverkaufsstelle,
        VerantwortlicherPfadiTrotzAllem,
        VerantwortlicherPr,

        Spezialfunktion,

        Ehrenmitglied,
        Passivmitglied
end