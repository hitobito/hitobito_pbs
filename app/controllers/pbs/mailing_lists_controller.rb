module Pbs::MailingListsController
    extend ActiveSupport::Concern

    included do

      self.permitted_attrs += [:mail_name_without_suffix]

      def assign_attributes
        super
        entry.mail_name = [permitted_params[:mail_name_without_suffix], entry.mail_name_suffix].join('.')
      end
    end
end