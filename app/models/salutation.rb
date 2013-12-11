class Salutation

  I18N_KEY_PREFIX = 'activerecord.models.salutation.available'

  attr_reader :person

  class << self

    def available
      I18n.t(I18N_KEY_PREFIX).each_with_object({}) do |s, h|
        h[s.first.to_s] = s.last[:label]
      end
    end

  end

  def initialize(person)
    @person = person
  end

  def label
    I18n.translate("#{I18N_KEY_PREFIX}.#{person.salutation}.label") if person.salutation?
  end

  def value
    return nil unless person.salutation?

    gender = person.gender || 'f'
    key = "#{I18N_KEY_PREFIX}.#{person.salutation}.value.#{gender}"
    I18n.translate(key,
                   first_name: person.first_name,
                   last_name: person.last_name,
                   nickname: person.nickname,
                   company_name: person.company_name,
                   title: person.title,
                   title_last_name: "#{person.title} #{person.last_name}".strip
                   )
  end

end