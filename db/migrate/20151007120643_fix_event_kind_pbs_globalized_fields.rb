class FixEventKindPbsGlobalizedFields < ActiveRecord::Migration[4.2]
  def up
    Event::Kind.add_translation_fields!({ documents_text: :text }, migrate_data: true)

    remove_column :event_kinds, :documents_text
  end

  def down
    fail 'translation data will be lost!'

    add_column(:event_kinds, :documents_text, :text)

    remove_column :event_kind_translations, :documents_text
  end
end
