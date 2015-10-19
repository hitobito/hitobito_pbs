# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventsController
  extend ActiveSupport::Concern

  included do
    before_action :remove_restricted, only: [:create, :update]

    prepend_before_action :entry, only: [:show_camp_application, :create_camp_application]

    before_render_show :load_participation_emails, if: :canceled?

    alias_method_chain :permitted_attrs, :superior_check
  end

  def show_camp_application
    pdf = Export::Pdf::CampApplication.new(entry)
    send_data pdf.render, type: :pdf, disposition: 'inline', filename: pdf.filename
  end

  def create_camp_application
    # Validierung, ob Anzahl Ausbildungstage und Lagerort/Kanton ausgefüllt sind.
    # eine Bestätigungsemail an den Coach, die Lagerleiter und den AL; an die PBS Geschäftsstelle (lager@pbs.ch); Bei Lagern mit Kanton = Ausland soll zusätzlich eine Nachricht an auslandlager@pbs.ch verschickt werden.
    # camp_submitted` = true setzen.
  end

  private

  def canceled?
    entry.is_a?(Event::Course) && entry.canceled?
  end

  def load_participation_emails
    @emails = Person.mailing_emails_for(entry.people)
  end

  def permitted_attrs_with_superior_check
    attrs = entry.class.used_attributes.dup
    attrs += self.class.permitted_attrs
    if entry.superior_attributes.present? && !can?(:modify_superior, entry)
      attrs -= entry.class.superior_attributes
    end
    attrs
  end

  def remove_restricted
    model_params.delete(:coach)
  end

end
