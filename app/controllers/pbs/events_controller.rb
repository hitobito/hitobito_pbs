# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventsController
  extend ActiveSupport::Concern

  included do
    before_action :remove_restricted, only: [:create, :update]
    before_action :check_checkpoint_attrs, only: [:create, :update]

    prepend_before_action :entry, only: [:show_camp_application, :create_camp_application]

    before_render_show :load_participation_emails, if: :canceled?

    alias_method_chain :permitted_attrs, :superior_and_coach_check
    alias_method_chain :list_entries, :canton
  end

  def show_camp_application
    pdf = Export::Pdf::CampApplication.new(entry)
    send_data pdf.render, type: :pdf, disposition: 'inline', filename: pdf.filename
  end

  def create_camp_application
    entry.camp_submitted = true
    if entry.valid?
      Event::CampMailer.submit_camp(entry).deliver_later
      entry.save!
      set_success_notice
    else
      flash[:alert] = "#{I18n.t('events.create_camp_application.flash.error')}" \
                      "<br />#{entry.errors.full_messages.join('; ')}"
    end
    redirect_to path_args(entry)
  end

  private

  def list_entries_with_canton
    if params[:filter].to_s == 'canton'
      model_scope_without_nesting.
        where(type: params[:type], canton: group.kantonalverband.cantons).
        in_year(year).order_by_date.preload_all_dates.uniq
    else
      list_entries_without_canton
    end
  end

  def canceled?
    entry.is_a?(Event::Course) && entry.canceled?
  end

  def load_participation_emails
    @emails = Person.mailing_emails_for(entry.people)
  end

  def permitted_attrs_with_superior_and_coach_check
    attrs = entry.used_attributes.dup
    attrs += self.class.permitted_attrs

    attrs = check_superior_attrs(attrs)
    attrs = check_coach_attrs(attrs)

    attrs
  end

  def check_superior_attrs(attrs)
    if entry.superior_attributes.present? && !can?(:modify_superior, entry)
      attrs -= entry.superior_attributes
    end
    attrs
  end

  def check_coach_attrs(attrs)
    if entry.is_a?(Event::Campy) && entry.coach != current_user
      attrs.delete(:coach_confirmed)
    end
    attrs
  end

  def remove_restricted
    model_params.delete(:coach)
  end

  def check_checkpoint_attrs
    if entry.is_a?(Event::Campy) && entry.leader != current_user
      Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |attr|
        model_params.delete(attr.to_s)
      end
    end
  end

end
