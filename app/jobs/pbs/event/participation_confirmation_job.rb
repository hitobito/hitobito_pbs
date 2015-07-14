# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationConfirmationJob
  extend ActiveSupport::Concern

  included do
    alias_method_chain :send_approval, :noop
    alias_method_chain :initialize, :current_user
    alias_method_chain :send_confirmation, :current_user

    self.parameters += [:current_user_id]

    attr_reader :current_user_id
  end

  def initialize_with_current_user(participation, current_user)
    @current_user_id = current_user.id
    @participation_id = participation.id
    store_locale
  end


  def send_confirmation_with_current_user
    if participation.person_id == current_user_id
      send_confirmation_without_current_user
    else
      if participation.person.email.present?
        Event::ParticipationMailer.confirmation_other(participation).deliver
      end
    end
  end

  def send_approval_with_noop; end
end
