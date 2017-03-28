# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


module Pbs::Person::AddRequestMailer
  extend ActiveSupport::Concern

  private

  define_method "#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_PERSON}_values_with_salutation" do
    send(:"#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_PERSON}_values_without_salutation").merge({
      'recipient-name-with-salutation' => person.salutation_value
    })
  end

  define_method "#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_RESPONSIBLES}_values_with_salutation" do
    send(:"#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_RESPONSIBLES}_values_without_salutation").merge({
      'recipient-names-with-salutation' => @responsibles.collect(&:salutation_value).join(', ')
    })
  end

  define_method "#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_APPROVED}_values_with_salutation" do
    send(:"#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_APPROVED}_values_without_salutation").merge({
      'recipient-name-with-salutation' => @requester.salutation_value
    })
  end

  define_method "#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_REJECTED}_values_with_salutation" do
    send(:"#{Person::AddRequestMailer::CONTENT_ADD_REQUEST_REJECTED}_values_without_salutation").merge({
      'recipient-name-with-salutation' => @requester.salutation_value
    })
  end

end
