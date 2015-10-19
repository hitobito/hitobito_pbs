# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplication

    include Translatable

    attr_reader :camp, :pdf

    delegate :text, :font_size, :move_down, :text_box, :cursor, :table,
             to: :pdf

    def initialize(camp)
      @camp = camp
    end

    def render
      @pdf = Prawn::Document.new(page_size: 'A4',
                                 page_layout: :portrait,
                                 margin: 2.cm)
      pdf.font_size 10

      render_sections

      pdf.number_pages(I18n.t('event.participations.print.page_of_pages'),
                       at: [0, 0],
                       align: :right,
                       size: 9)
      pdf.render
    end

    def filename
      "TODO.pdf"
    end

    private

    def render_sections
      @section_count = 0
      render_title
      render_group
      render_leader
      render_assistant_leaders
      render_dates
      render_location
      render_j_s
      render_state
      render_abteilungsleitung
      render_coach
    end

    def render_title
      font_size(20) do
        text translate('title', camp: camp.name), style: :bold
      end
      move_down_line
    end

    def render_group
      section('group_header') do
      end
    end

    def render_leader
      section('leader_header') do
        leader = camp.participations_for(Event::Camp::Role::Leader).first.try(:person)
        if leader
          with_label('name', leader.to_s)
          with_label('address', leader.address)
          with_label('zip_town', [leader.zip_code, leader.town].compact.join(' '))
          with_label('birthday', I18n.l(leader.birthday))
          with_label('qualifications', active_qualifications(leader))
        end
      end
    end

    def render_assistant_leaders
      section('assistant_leaders_header') do
        leaders = camp.participations_for(Event::Camp::Role::AssistantLeader).collect(&:person)
        cells = leaders.collect do |person|
          [person.to_s, person.birthday.year.to_s, active_qualifications(person)]
        end
        table(cells, width: 500, cell_style: { border_width: 0.25 })
      end
    end

    def render_dates

    end

    def render_location

    end

    def render_j_s

    end

    def render_state

    end

    def render_abteilungsleitung
    end

    def render_coach

    end

    def section(header)
      @section_count += 1
      heading { text "#{@section_count}. #{translate(header)}", style: :bold }
      move_down_line
      yield
      2.times { move_down_line }
    end

    def heading
      font_size(14) { yield }
    end

    def with_label(key, value)
      label = translate(key)
      text_box(label, at: [0, cursor], width: 120, style: :italic)
      text_box(value, at: [120, cursor])
      move_down_line
    end

    def move_down_line(line = 12)
      move_down(line)
    end

    def active_qualifications(person)
      QualificationKind.joins(:qualifications).
                        where(qualifications: { person_id: person.id }).
                        merge(Qualification.active).
                        uniq.
                        list.
                        collect(&:to_s).
                        join("\n")
    end

  end
end
