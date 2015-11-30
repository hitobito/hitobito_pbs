# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplication

    include Translatable

    attr_reader :camp, :pdf, :data

    delegate :text, :font_size, :move_down, :text_box, :cursor, :table,
      to: :pdf
    delegate :t, :l, to: I18n

    def initialize(camp)
      @camp = camp
      @data = CampApplicationData.new(camp)
    end

    def render
      @pdf = Prawn::Document.new(page_size: 'A4',
                                 page_layout: :portrait,
                                 margin: 2.cm)
      pdf.font_size 10

      render_sections

      pdf.number_pages(t('event.participations.print.page_of_pages'),
                       at: [0, 0],
                       align: :right,
                       size: 9)
      pdf.render
    end

    def filename
      title + '.pdf'
    end

    private

    def render_sections
      @section_count = 0
      render_title
      render_group
      render_leader
      render_assistant_leaders
      render_camp
      render_j_s
      render_state
      render_abteilungsleitung
      render_coach
    end

    def render_title
      font_size(20) do
        text title, style: :bold
      end
      move_down_line
    end

    def render_group
      section('group_header') do
        with_label('abteilung', data.abteilung_name)
        with_label('einheit', data.einheit_name) if data.einheit_name
        with_label('kantonalverband', data.kantonalverband) if data.kantonalverband
        render_expected_participant_table
      end
    end

    def render_expected_participant_table
      move_down_line
      text translate('expected_participants')
      move_down_line
      cells = []
      cells << data.expected_participant_table_header
      cells << data.expected_participant_table_row(:f)
      cells << data.expected_participant_table_row(:m)
      table(cells, cell_style: { align: :center, border_width: 0.25, width: 50})
    end

    def render_leader
      section('leader_header') do
        leader = data.camp_leader
        if leader
          render_person(leader)
          with_label('qualifications', data.active_qualifications(leader))
        else
          text_nobody
        end
      end
    end

    def render_assistant_leaders
      section('assistant_leaders_header') do
        cells = data.camp_assistant_leaders.collect do |person|
          [person.to_s, person.birthday.try(:year).to_s, data.active_qualifications(person)]
        end
        if cells.present?
          header_row = assistant_leaders_header_row
          cells = cells.unshift(header_row)
          table(cells, width: 500,
                cell_style: { border_width: 0.25 },
                column_widths: [210, 55, 235])
        else
          text_nobody
        end
      end
    end

    def render_camp
      section('camp') do
        sub_section('camp_dates') do
          render_dates
          move_down_line
          labeled_camp_attr(:camp_days)
        end
        sub_section('camp_location') do
          render_location
        end
      end
    end

    def render_dates
      camp.dates.each do |d|
        labeled_value(d.duration.to_s, d.label)
      end
    end

    def render_location
      labeled_camp_attr(:canton)
      labeled_camp_attr(:location)
      labeled_camp_attr(:coordinates)
      labeled_camp_attr(:altitude)
      labeled_camp_attr(:emergency_phone)
      labeled_camp_attr(:landlord)
      labeled_camp_attr(:landlord_permission_obtained)
    end

    def render_j_s
      section('j_s') do
        blank_text = "(#{t('global.nobody')})"
        labeled_camp_attr(:j_s_kind)
        labeled_value(translate('js_security'), data.js_security_value)
        labeled_camp_attr(:advisor_mountain_security, blank_text)
        labeled_camp_attr(:advisor_water_security, blank_text)
        labeled_camp_attr(:advisor_snow_security, blank_text)
      end
    end

    def render_state
      section('state') do
        labeled_camp_attr(:updated_at)
        labeled_camp_attr(:state)
      end
    end

    def render_abteilungsleitung
      section('abteilungsleitung') do
        abteilungsleitung = camp.abteilungsleitung
        render_person(abteilungsleitung, false) if abteilungsleitung
        labeled_camp_attr(:al_present)
        labeled_camp_attr(:al_visiting)
      end
    end

    def render_coach
      section('coach') do
        coach = camp.coach
        render_person(coach, false) if coach
        labeled_camp_attr(:coach_visiting)
      end
    end

    def render_person(person, details = true)
      with_label('name', person)
      with_label('address', person.address)
      with_label('zip_town', [person.zip_code, person.town].compact.join(' '))
      labeled_email(person)
      labeled_phone_number(person, 'Privat')
      labeled_phone_number(person, 'Mobil')
      with_label('birthday', person.birthday.presence && l(person.birthday)) if details
    end

    def section(header)
      @section_count += 1
      heading { text "#{@section_count}. #{translate(header)}", style: :bold }
      move_down_line
      yield
      2.times { move_down_line }
    end

    def sub_section(header)
      heading { text translate(header), style: :bold, size: 10 }
      move_down_line
      yield
      move_down_line
    end

    def heading
      font_size(14) { yield }
    end

    def with_label(key, value)
      label = translate(key)
      labeled_value(label, value)
    end

    def labeled_camp_attr(attr, show_blank = false)
      value = data.camp_attr_value(attr)
      return unless value.present? || show_blank
      label = data.t_camp_attr(attr.to_s)
      value = show_blank unless value.present?
      labeled_value(label, value)
    end

    def labeled_phone_number(person, phone_label)
      value = data.phone_number(person, phone_label)
      return unless value.present?
      label = t("events.fields_pbs.phone_#{phone_label.downcase}")
      labeled_value(label, value)
    end

    def labeled_email(person)
      value = person.email
      return unless value.present?
      label = t("events.fields_pbs.email")
      labeled_value(label, value)
    end

    def labeled_value(label, value)
      cells = [[label, value.to_s]]
      cell_style = { border_width: 0, padding: 0 }
      table(cells, cell_style: cell_style, column_widths: [180, 300]) do
        column(0).style font_style: :italic
      end
    end

    def move_down_line(line = 12)
      move_down(line)
    end

    def text_nobody
      text "(#{t('global.nobody')})"
    end

    def title
      @title ||= translate('title', camp: camp.name)
    end

    def assistant_leaders_header_row
      name = translate('assistant_leader_name')
      year = translate('assistant_leader_year')
      qualifications = translate('assistant_leader_qualifications')
      [name, year, qualifications]
    end

  end
end
