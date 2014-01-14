# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

Census.seed(:year,
  {year: 2013,
   start_at: Date.new(2013,8,1),
   finish_at: Date.new(2013,10,31)}
)

unless MemberCount.exists?
  Group::Abteilung.find_each do |abteilung|
    MemberCounter.new(2013, abteilung).count!
  end
end