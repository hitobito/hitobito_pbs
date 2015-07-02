# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: member_counts
#
#  id                 :integer          not null, primary key
#  kantonalverband_id :integer          not null
#  region_id          :integer
#  abteilung_id       :integer          not null
#  year               :integer          not null
#  leiter_f           :integer
#  leiter_m           :integer
#  biber_f            :integer
#  biber_m            :integer
#  woelfe_f           :integer
#  woelfe_m           :integer
#  pfadis_f           :integer
#  pfadis_m           :integer
#  pios_f             :integer
#  pios_m             :integer
#  rover_f            :integer
#  rover_m            :integer
#  pta_f              :integer
#  pta_m              :integer
#


#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

Fabricator(:member_count) do
  year { 2012 }
end
