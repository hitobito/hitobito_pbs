class ReplaceCorrespondanceLanguageWithCoreLanguage < ActiveRecord::Migration[6.1]
  def change
    Person.where(correspondence_language: nil).update_all(correspondence_language: :de)
    Person.update_all("language = correspondence_language")
    remove_column :people, :correspondence_language, :string, limit: 5
  end
end
