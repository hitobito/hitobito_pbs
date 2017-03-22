# vim:fileencoding=utf-8

module Pbs::Event::RegisterMailer
  extend ActiveSupport::Concern

  private

  define_method "#{Event::RegisterMailer::CONTENT_REGISTER_LOGIN}_values" do
    super.merge({
      'recipient-name-with-salutation' => @recipient.salutation_value
    })
  end

end
