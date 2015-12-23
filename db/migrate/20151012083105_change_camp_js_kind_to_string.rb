class ChangeCampJsKindToString < ActiveRecord::Migration
  def change
    change_column :events, :j_s_kind, :string
  end
end
