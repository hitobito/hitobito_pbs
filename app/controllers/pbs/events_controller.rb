# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventsController
  extend ActiveSupport::Concern

  included do
    self.permitted_attrs += [:tentative_applications]

    before_render_show :load_participation_emails, if: :canceled?
    alias_method_chain :permitted_attrs, :superior_check

    skip_load_and_authorize_resource only: :tentatives
  end

  def tentatives
    #TODO what permission?
    #TODO irgendwas mit views war noch nicht in ordnung
    authorize!(:update, entry)

    @grouped_participations = entry.
      participations.
      tentative.
      includes(person: :primary_group).
      group_by { |p| p.person.primary_group }
  end

  private

  def canceled?
    entry.is_a?(Event::Course) && entry.canceled?
  end

  def load_participation_emails
    @emails = entry.participations.includes(:person).pluck('people.email').uniq
  end

  def permitted_attrs_with_superior_check
    attrs = entry.class.used_attributes.dup
    attrs += self.class.permitted_attrs
    if entry.class.superior_attributes.present? && !superior_role?
      attrs -= entry.class.superior_attributes
    end
    attrs
  end

  def superior_role?
    current_user.roles.any? { |role| superior_roles.include?(role.class) }
  end

  def superior_roles
    [Group::Bund::AssistenzAusbildung,
     Group::Bund::MitarbeiterGs]
  end
end
