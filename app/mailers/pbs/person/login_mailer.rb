# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


module Pbs::Person::LoginMailer
  extend ActiveSupport::Concern

  private

  define_method "#{Person::LoginMailer::CONTENT_LOGIN}_values" do
    super.merge({
      'recipient-name-with-salutation' => @recipient.salutation_value
    })
  end

end
