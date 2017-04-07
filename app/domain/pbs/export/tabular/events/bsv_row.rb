# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

module Pbs::Export::Tabular::Events
  module BsvRow
    extend ActiveSupport::Concern

    included do
      alias_method :language_count, :language_count_pbs
    end

    def language_count_pbs
      langs = [:language_de, :language_fr, :language_it, :language_en]
      count = 0
      langs.each { |l| count += 1 if entry.send(l) }
      count
    end

  end
end
