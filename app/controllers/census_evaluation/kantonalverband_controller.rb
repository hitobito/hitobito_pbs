#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CensusEvaluation::KantonalverbandController < CensusEvaluation::BaseController
  # self.sub_group_type = Group::Region
  self.sub_group_type = Group::Abteilung
end
