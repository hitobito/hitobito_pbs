module Pbs::Person::AddRequestMailer
  extend ActiveSupport::Concern

  private

  define_method "#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_PERSON}_values" do
    super.merge({
      'recipient-name-with-salutation' => person.salutation_value
    })
  end

  define_method "#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_RESPONSIBLES}_values" do
    super.merge({
      'recipient-names-with-salutation' => @responsibles.collect(&:salutation_value).join(', ')
    })
  end

  define_method "#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_APPROVED}_values" do
    super.merge({
      'recipient-name-with-salutation' => requester.salutation_value
    })
  end

  define_method "#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_REJECTED}_values" do
    super.merge({
      'recipient-name-with-salutation' => requester.salutation_value
    })
  end

end
