class ChangeCampJsKindToString < ActiveRecord::Migration[4.2]
  def change
    change_column :events, :j_s_kind, :string
  end
end
