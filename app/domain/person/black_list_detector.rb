#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class Person::BlackListDetector
  attr_reader :person

  def initialize(person, changes = nil)
    @person = person
    @person = Person.new(changes) if changes.present?
  end

  def occures?
    matching_attributes? || matching_phone_number?
  end

  private

  def matching_attributes?
    bl = BlackList.arel_table

    BlackList.where(
      bl[:first_name].eq(person.first_name).and(bl[:last_name].eq(person.last_name)).
      or(bl[:email].eq(person.email)).
      or(bl[:pbs_number].eq(person.pbs_number))
    ).present?
  end

  def matching_phone_number?
    return false if person.phone_numbers.blank?

    black_list_numbers = strip_numbers(BlackList.pluck(:phone_number))
    person_numbers = strip_numbers(person.phone_numbers.pluck(:number))

    (black_list_numbers & person_numbers).present?
  end

  def strip_numbers(numbers)
    numbers.map do |number|
      next if number.blank?
      number.
        gsub(/\D/, ''). # Remove all none digits
        match(/\d{9}$/). # Take the last 9 digits
        to_s.presence
    end.compact
  end

end
