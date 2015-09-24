class AddQualificationKindManual < ActiveRecord::Migration
  def change
    add_column :qualification_kinds, :manual, :boolean, null: false, default: true

    QualificationKind.reset_column_information
  end
end
