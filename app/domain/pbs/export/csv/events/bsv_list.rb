# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

module Pbs::Export::Csv::Events
  module BsvList
    extend ActiveSupport::Concern

    included do
      alias_method :to_csv, :to_csv_without_headers
    end

    def to_csv_without_headers(generator)
      list.each do |entry|
        generator << values(entry)
      end
    end

  end
end
