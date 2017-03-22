class AddSalutationPlaceholdersToCustomContents < ActiveRecord::Migration

  def up
    change_custom_content do |placeholders|
      placeholders.push 'recipient-name-with-salutation' if placeholders.include? 'recipient-name'
      placeholders.push 'recipient-names-with-salutation' if placeholders.include? 'recipient-names'

      placeholders
    end
  end

  def down
    change_custom_content do |placeholders|
      placeholders.delete 'recipient-name-with-salutation'
      placeholders.delete 'recipient-names-with-salutation'

      placeholders
    end
  end

  private

  def change_custom_content
    keys = [
      # PBS Mailer
      GroupMembershipMailer::CONTENT_GROUP_MEMBERSHIP,
      Event::ParticipationMailer::CONTENT_CONFIRMATION_OTHER,
      Event::CampMailer::CONTENT_SUBMIT_REMINDER,

      # Core Mailer
      Event::ParticipationMailer::CONTENT_APPROVAL,
      Event::ParticipationMailer::CONTENT_CANCEL,
      Event::ParticipationMailer::CONTENT_CONFIRMATION,
      Event::RegisterMailer::CONTENT_REGISTER_LOGIN,
      Person::AddRequestMailer::CONTENT_ADD_REQUEST_APPROVED,
      Person::AddRequestMailer::CONTENT_ADD_REQUEST_PERSON,
      Person::AddRequestMailer::CONTENT_ADD_REQUEST_REJECTED,
      Person::AddRequestMailer::CONTENT_ADD_REQUEST_RESPONSIBLES,
      Person::LoginMailer::CONTENT_LOGIN,
    ]

    keys.each do |key|
      say_with_time "Updating CustomContent #{key.inspect}" do
        cc = CustomContent.find_by(key: key)
        if cc.nil?
          say "not found"
          next
        end

        placeholders = cc.placeholders_optional.split(', ')
        placeholders = yield placeholders
        cc.placeholders_optional = placeholders.uniq.sort.join(', ')
        cc.save!
      end
    end
  end

end
