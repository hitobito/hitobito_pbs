#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::PhoneNumber
  extend ActiveSupport::Concern

  included do
    after_save :send_black_list_mail, if: :person_blacklisted?
  end

  private

  def send_black_list_mail
    contactable.send_black_list_mail
  end

  def person_blacklisted?
    contactable.is_a?(Person) && contactable.black_listed?
  end
end
