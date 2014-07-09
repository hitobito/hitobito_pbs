module Pbs::GroupSerializer
  extend ActiveSupport::Concern

  included do
    extension(:attrs) do |_|
      map_properties(*item.used_attributes(:pbs_shortname, :website, :bank_account, :pta, :vkp,
                                           :pbs_material_insurance, :description))
    end
  end

end