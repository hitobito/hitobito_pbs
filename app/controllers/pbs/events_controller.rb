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

    alias_method_chain :permitted_attrs, :superior_and_coach_check
  end

  def show_camp_application
    pdf = Export::Pdf::CampApplication.new(entry)
    send_data pdf.render, type: :pdf, disposition: 'inline', filename: pdf.filename
  end

  def create_camp_application
    if validate_present?(:camp_days, :canton)
      Event::CampMailer.submit_camp(entry).deliver_later
      entry.update!(camp_submitted: true)
      set_success_notice
    end
    redirect_to path_args(entry)
  end

  private

  def canceled?
    entry.is_a?(Event::Course) && entry.canceled?
  end

  def load_participation_emails
    @emails = Person.mailing_emails_for(entry.people)
  end

  def permitted_attrs_with_superior_and_coach_check
    attrs = entry.class.used_attributes.dup
    attrs += self.class.permitted_attrs

    attrs = check_superior_attrs(attrs)
    attrs = check_coach_attrs(attrs)

    attrs
  end

  def check_superior_attrs(attrs)
    if entry.superior_attributes.present? && !can?(:modify_superior, entry)
      attrs -= entry.class.superior_attributes
    end
    attrs
  end

  def check_coach_attrs(attrs)
    if entry.is_a?(Event::Camp) && entry.coach != current_user
      attrs.delete(:coach_confirmed)
    end
    attrs
  end

  def remove_restricted
    model_params.delete(:coach)
  end

  def validate_present?(*attrs)
    errors = attrs.select { |attr| entry.send(attr).blank? }.
                   collect { |attr| blank_message(attr) }
    if errors.present?
      errors.unshift(I18n.t('events.create_camp_application.flash.error'))
      flash[:alert] = errors.join("\n")
    end
    errors.blank?
  end

  def blank_message(attr)
    Event::Camp.human_attribute_name(attr) + ' ' +
      I18n.t('errors.messages.blank', attribute: attr) + '.'
  end

end
