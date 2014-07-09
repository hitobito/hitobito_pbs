module Pbs::PersonSerializer
  extend ActiveSupport::Concern

  included do
    extension(:details) do |_|
      map_properties :pbs_number, :j_s_number, :salutation_value, :correspondence_language,
                     :grade_of_school, :brother_and_sisters, :entry_date, :leaving_date
    end
  end

end