class AdaptOldMemberCountsToRegionalDisplay < ActiveRecord::Migration
  def change
    say_with_time "Updating Regions of Member-Counts" do
      MemberCount.find_each do |mc|
        new_region = mc.abteilung.parent
        mc.region_id = new_region.id if new_region.is_a?(Group::Region)
        mc.save!
      end
    end
  end
end
