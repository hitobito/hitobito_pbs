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


  class Abteilungsleitung < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

  class AbteilungsleitungStv < ::Role
    self.permissions = [:layer_full, :contact_data]
  end

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

  class Heimverwaltung < ::Role
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

  class StufenleitungBiber < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleitungWoelfe < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleitungPfadi < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleitungPio < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleitungRover < ::Role
    self.permissions = [:layer_read]
  end

  class StufenleitungPta < ::Role
    self.permissions = [:layer_read]
  end

  class VerantwortungMaterialverkaufsstelle < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPfadiTrotzAllem < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VerantwortungPr < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class VizePraesidium < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  class Webmaster < ::Role
    self.permissions = [:group_read, :contact_data]
  end

  roles Abteilungsleitung,
        AbteilungsleitungStv,
        Sekretariat,
        Adressverwaltung,
        Praesidium,
        VizePraesidium,
        PraesidiumApv,
        Praeses,
        Beisitz,

        StufenleitungBiber,
        StufenleitungWoelfe,
        StufenleitungPfadi,
        StufenleitungPio,
        StufenleitungRover,
        StufenleitungPta,

        Kassier,
        Revisor,
        Redaktor,
        Webmaster,
        Coach,

        VerantwortungMaterialverkaufsstelle,
        VerantwortungPfadiTrotzAllem,
        VerantwortungPr,

        Spezialfunktion,

        Ehrenmitglied,
        Passivmitglied
end
