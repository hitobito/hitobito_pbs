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
        add_counts(labels)
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
      labels[:bsv_days] = 'BSV Tage'
      labels[:bsv_eligible_participations_count] = 'Berechtigte Teilnehmende (bis 30)'
      labels[:bsv_eligible_attendance_summary] = 'Berechtigte Teilnehmende (bis 30) x Tage'
      labels[:bsv_eligible_attendances] = 'Berechtigte Tage'
      labels[:leader_count] = 'Kursleitende'
      labels[:all_participants_count] = 'Teilnehmende Total (inkl. Kursleitende)'
      labels[:all_participants_attendance_summary] = 'Teilnehmende Total x Tage'
      labels[:all_participants_attendances] = 'Total Tage'
      labels[:canton_count] = 'Wohnkantone der TN'
      labels[:language_count] = 'Sprachen'
    end

    def add_advisor_labels(labels)
      labels[:id] = 'LKB Personen-ID'
      labels[:first_name] = 'LKB Vorname'
      labels[:last_name] = 'LKB Nachname'
      labels[:nickname] = 'LKB Pfadiname'
      labels[:address] = 'LKB Adresse'
      labels[:zip_code] = 'LKB PLZ'
      labels[:town] = 'LKB Ort'
      labels[:country] = 'LKB Land'
      labels[:email] = 'LKB Email'
      labels[:salutation_value] = 'LKB Anrede'
    end

  end
end
