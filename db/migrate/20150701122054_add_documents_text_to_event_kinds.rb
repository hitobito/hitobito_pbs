class AddDocumentsTextToEventKinds < ActiveRecord::Migration
  def change
    add_column(:event_kinds, :documents_text, :text)
  end
end
