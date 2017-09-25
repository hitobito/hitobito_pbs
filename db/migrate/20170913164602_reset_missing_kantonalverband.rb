class ResetMissingKantonalverband < ActiveRecord::Migration
  def change
    # due to callback-issues, many kantonalverband-ids were not set
    say_with_time 'Infering the Kantonalverband from the primary group' do
      Person.where(kantonalverband_id: nil)
            .where.not(primary_group_id: nil)
            .includes(:groups)
            .find_each(&:reset_kantonalverband!)
    end

    # some people don't have a primary_group set, but other groups
    say_with_time 'Infering the Kantonalverband from the groups' do
      with_groups = []
      Person.where(kantonalverband_id: nil, primary_group_id: nil)
            .includes(:groups)
            .find_each do |person|
        with_groups << person unless person.group_ids.empty?
      end
      with_groups.each(&:reset_kantonalverband!)
    end
  end
end
