# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventsController
  extend ActiveSupport::Concern

  included do
    before_render_show :load_participation_emails, if: :canceled?
  end

  private

  def canceled?
    entry.canceled?
  end

  def load_participation_emails
    @emails = entry.participations.includes(:person).pluck('people.email').uniq
  end

end
