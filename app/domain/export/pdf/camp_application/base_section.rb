# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplication
    class BaseSection
      include Translatable
      include Helpers
      include Prawn::View

      def initialize(document, context: nil, **options)
        @document = document
        @context = context
      end
    end
  end
end
