# encoding: utf-8

module Pbs::Person
  extend ActiveSupport::Concern

  included do
    Person::PUBLIC_ATTRS << :title << :salutation

    attr_accessible :salutation, :title, :grade_of_school, :entry_date, :leaving_date,
                    :j_s_number, :correspondence_language, :brother_and_sisters

    validates :salutation, inclusion: { in: ->(person) { Salutation.available.keys } , allow_blank: true }


    define_partial_index do
      indexes title, j_s_number
    end

    alias_method_chain :full_name, :title
  end

  def salutation_label
    Salutation.new(self).label
  end

  def salutation_value
    Salutation.new(self).value
  end

  def pbs_number
    sprintf('%09d', id).gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1-")
  end

  def full_name_with_title
    "#{title} #{full_name_without_title}".strip
  end

end
