# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplication

    include Translatable

    attr_reader :camp, :pdf

    delegate :text, :font_size, :move_down,
             to: :pdf

    def initialize(camp)
      @camp = camp
    end

    def render
      @pdf = Prawn::Document.new(page_size: 'A4',
                                 page_layout: :portrait,
                                 margin: 2.cm)
      pdf.font_size 9

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
      render_assistand_leaders
      render_info
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

    end

    def render_assistand_leaders

    end

    def render_info

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
      font_size(11) { yield }
    end

    def move_down_line(line = 10)
      move_down(line)
    end

  end
end
