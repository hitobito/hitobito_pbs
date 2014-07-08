#  Copyright (c) 2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_cevi and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cevi.

json.extract!(entry,
              *entry.used_attributes(:pbs_shortname, :website, :bank_account, :pta, :vkp,
                                     :pbs_material_insurance, :description))
