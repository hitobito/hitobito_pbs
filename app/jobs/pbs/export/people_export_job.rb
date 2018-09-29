# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::Export::PeopleExportJob
  extend ActiveSupport::Concern

  included do
    alias_method_chain :exporter, :detail
  end

  def exporter_with_detail
    return Pbs::Export::Tabular::People::HouseholdsFull if  @options[:household_details]
    exporter_without_detail
  end

end
