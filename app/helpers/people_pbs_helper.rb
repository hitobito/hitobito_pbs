module PeoplePbsHelper

  def format_correspondence_language(person)
    lang = person.correspondence_language
    if lang
      Settings.application.languages.to_hash.with_indifferent_access[lang]
    end
  end
end