module Pbs::MailingList
    extend ActiveSupport::Concern

    included do
      validate :mail_name_includes_pbs_shortname

      attr_accessor :mail_name_without_suffix

      def mail_name_includes_pbs_shortname
        unless mail_name.match(/(.+)\.(.+)$/)[2] == mail_name_suffix
            errors.add(:mail_name, :invalid)
        end 
      end
      
      def mail_name_without_suffix
        mail_name.delete_suffix(".#{mail_name_suffix}")
      end

      def mail_name_suffix
        group.pbs_shortname.downcase
      end
    end
end
    