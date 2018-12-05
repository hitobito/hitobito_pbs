# encoding: utf-8

#  Copyright (c) 201, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Export::Tabular::Events
  class AdvancedBsvList < BsvList

    def attribute_labels
      {}.tap do |labels|
        add_main_labels(labels)
        add_advisor_labels(labels)
      end
    end

    def add_main_labels(labels)
      labels[:vereinbarungs_id_fiver] = 'Vereinbarung-ID-FiVer'
      labels[:kurs_id_fiver] = 'Kurs-ID-FiVer'
      labels[:kurs_kind] = 'Kursart'
      labels[:kantonalverband] = 'Kantonalverband'
      labels[:region] = 'Regionalverband'
      labels[:number] = 'Kursnummer'
      labels[:first_event_date] = 'Start Datum'
      labels[:last_event_date] = 'End Datum'
      labels[:location] = 'Kursort'
    end

    def add_counts(labels)
      labels[:training_days] = 'Ausbildungstage'
      labels[:participant_count] = 'Teilnehmende (17-30)'
      labels[:leader_count] = 'Kursleitende'
      labels[:canton_count] = 'Wohnkantone der TN'
      labels[:language_count] = 'Sprachen'
    end

    def add_advisor_labels(labels)
      labels[:id] = 'Personen-ID'
      labels[:first_name] = 'Vorname'
      labels[:last_name] = 'Nachname'
      labels[:nickname] = 'Pfadiname'
      labels[:address] = 'Adresse'
      labels[:zip_code] = 'PLZ'
      labels[:town] = 'Ort'
      labels[:country] = 'Land'
      labels[:email] = 'Email'
      labels[:salutation_value] = 'Anrede'
    end

  end
end
