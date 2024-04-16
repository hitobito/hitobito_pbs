# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Qualifier::QualifyAction

  extend ActiveSupport::Concern

  included do
    alias_method_chain :create, :participation
  end

  private

  def create_with_participation(kind)
    create_without_participation(kind).tap do |q|
      q.update!(event_participation: participation)
    end
  end

  def participation
    @participation ||= ::Event::Participation.find_by(event: @event, person: @person)
  end

end
