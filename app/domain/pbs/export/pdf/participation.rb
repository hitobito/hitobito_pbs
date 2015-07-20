# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Export::Pdf
  module Participation

    class DocumentsText < Export::Pdf::Participation::Section
      def render
        return unless event_with_kind?
        render_documents_text
      end

      def render_documents_text
        return unless event.kind.documents_text.present?
        heading { text I18n.t('activerecord.attributes.event/kind.documents_text'), style: :bold }
        move_down_line
        text event.kind.documents_text
        move_down_line
      end
    end

    class Runner < Export::Pdf::Participation::Runner

      private

      def sections
        [Export::Pdf::Participation::Header,
         Export::Pdf::Participation::PersonAndEvent,
         Export::Pdf::Participation::Specifics,
         Export::Pdf::Participation::Confirmation,
         Export::Pdf::Participation::EventDetails,
         DocumentsText,
         Export::Pdf::Participation::GeneralInformation]
      end
    end

  end
end
