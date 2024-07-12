#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplication
    include Translatable
    include Helpers
    include Prawn::View

    def initialize(camp)
      @camp = camp
      @context = ViewModel.new(camp)
      @section_count = 0
      @document = Prawn::Document.new(page_size: "A4",
        page_layout: :portrait,
        margin: 2.cm)
    end

    def title
      @title ||= translate("title", camp: @camp.name)
    end

    def render
      font_size 9
      render_sections
      render_page_numbers
      @document.render
    end

    def filename
      title + ".pdf"
    end

    private

    def render_sections
      render_logos
      render_title
      GroupSection.new(@document, context: @context).render
      LeadersSection.new(@document, context: @context).render
      break_page_if_under(200)
      CampSection.new(@document, context: @context).render
      break_page_if_under(120)
      RegistrationSection.new(@document, context: @context).render
      break_page_if_under(120)
      SupervisionSection.new(@document, context: @context).render
    end

    def break_page_if_under(value)
      start_new_page && move_cursor_to(bounds.top) if cursor < value
    end

    def render_logos
      image_path = Wagons.find_wagon(__FILE__).root.join("app", "assets", "images")
      image image_path.join("logo_pbs.png"), at: [0, bounds.top_left[1] + 40], fit: [200, 55]

      return if @camp.j_s_kind.blank?

      image image_path.join("logo_js.png"),
        at: [bounds.top_right[0] - 40, bounds.top_left[1] + 40], fit: [200, 55]
    end

    def render_page_numbers
      number_pages(I18n.t("event.participations.print.page_of_pages"),
        at: [0, -20],
        align: :right,
        size: 9)
    end

    def render_title
      move_down 28
      text title, style: :bold, size: 14
    end
  end
end
