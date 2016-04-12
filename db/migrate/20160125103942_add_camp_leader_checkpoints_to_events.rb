class AddCampLeaderCheckpointsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :lagerreglement_applied, :boolean, null: false, default: false
    add_column :events, :kantonalverband_rules_applied, :boolean, null: false, default: false
    add_column :events, :j_s_rules_applied, :boolean, null: false, default: false
  end
end
