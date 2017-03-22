module Pbs::Person::LoginMailer
  extend ActiveSupport::Concern

  private

  define_method "#{Person::LoginMailer::CONTENT_LOGIN}_values" do
    super.merge({
      'recipient-name-with-salutation' => @recipient.salutation_value
    })
  end

end
