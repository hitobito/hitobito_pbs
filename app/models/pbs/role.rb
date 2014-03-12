module Pbs::Role
  extend ActiveSupport::Concern

  included do
    attr_accessible :created_at, :deleted_at

    validate :assert_valid_dates

    def assert_valid_dates
      now = Time.zone.now
      prefix = 'activemodel.errors.messages'


      if created_at
        if now < created_at
          errors.add(:created_at, I18n.t("#{prefix}.must_be_in_the_past"))
        end

        if deleted_at
          if now < deleted_at
            errors.add(:deleted_at, I18n.t("#{prefix}.must_be_in_the_past"))
          end

          if deleted_at < created_at
            errors.add(:deleted_at, I18n.t("#{prefix}.cannot_be_before", other: I18n.l(created_at.to_date)))
          end
        end
      end
    end
  end
end

