#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventsController
  extend ActiveSupport::Concern

  included do
    before_action :remove_restricted, only: [:create, :update]
    before_action :check_checkpoint_attrs, only: [:create, :update]
    before_action :merge_supercamp_data, only: [:new, :edit]

    prepend_before_action :entry, only: CrudController::ACTIONS +
      [:show_camp_application, :create_camp_application]
    prepend_before_action :preview_camp_application_validation, only: :show

    before_render_show :load_participation_emails, if: :canceled?
    before_render_form :load_canton_specific_help_texts

    alias_method_chain :edit, :assign_attributes
    alias_method_chain :permitted_attrs, :superior_and_coach_check
    alias_method_chain :sort_expression, :canton
    alias_method_chain :assign_contact_attrs, :supercamp_flag

    # Merge all hashes in permitted_attrs and move them to the end of the list, so we can more
    # easily inject new nested attrs
    self.permitted_attrs = permitted_attrs.each_with_object([[], {}]) do |attr, result|
      result[0] << attr unless attr.is_a? Hash
      result[1].merge! attr if attr.is_a? Hash
    end.reduce(:<<)

    permitted_attrs.last[:application_questions_attributes] << :pass_on_to_supercamp
    permitted_attrs.last[:admin_questions_attributes] << :pass_on_to_supercamp
  end

  def edit_with_assign_attributes
    assign_attributes if model_params
    edit_without_assign_attributes
  end

  def sort_expression_with_canton
    return sort_expression_without_canton unless params[:sort] == "canton"
    sorted_keys = canton_labels_with_abroad.invert.sort.collect(&:second)
    expressions = sorted_keys.each_with_index.collect do |key, index|
      "WHEN events.canton = '#{key}' then #{index + 1}"
    end

    <<-SQL
      CASE
        WHEN events.canton = '' OR events.canton IS NULL THEN 0
        #{expressions.join("\n")}
      END #{sort_dir}
    SQL
  end

  def canton_labels_with_abroad
    Cantons.labels.merge(Event::Camp::ABROAD_CANTON =>
                         Cantons.full_name(Event::Camp::ABROAD_CANTON))
  end

  def assign_contact_attrs_with_supercamp_flag
    contact_attrs = assign_contact_attrs_without_supercamp_flag

    supercamp_contact_attrs = model_params.delete(:contact_attrs_passed_on_to_supercamp)
    return contact_attrs if supercamp_contact_attrs.blank?
    entry.contact_attrs_passed_on_to_supercamp =
      supercamp_contact_attrs.reject { |_, v| v == "0" }.keys

    contact_attrs
  end

  def preview_camp_application_validation # rubocop:todo Metrics/AbcSize
    return unless entry.is_a?(Event::Campy)
    return unless [entry.leader, entry.coach, entry.abteilungsleitung].include? current_person
    return if entry.camp_submitted?

    entry.camp_submitted_at = Time.zone.now.to_date
    if entry.valid?
      flash.now[:notice] = I18n.t("events.create_camp_application.flash.preview_success").to_s
    else
      flash.now[:warning] = "#{I18n.t("events.create_camp_application.flash.preview")}" \
                        "<br />#{entry.errors.full_messages.to_sentence}"
    end
    entry.restore_attributes # restore the simulated change to camp_submitted_at
  end

  def show_camp_application
    pdf = Export::Pdf::CampApplication.new(entry)
    send_data pdf.render, type: :pdf, disposition: "inline", filename: pdf.filename
  end

  def create_camp_application # rubocop:todo Metrics/AbcSize
    entry.camp_submitted_at = Time.zone.now.to_date
    if entry.save
      Event::CampMailer.submit_camp(entry).deliver_later
      set_success_notice
    else
      flash[:alert] = "#{I18n.t("events.create_camp_application.flash.error")}" \
                      "<br />#{entry.errors.full_messages.to_sentence}"
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

  def load_canton_specific_help_texts
    @canton_specific_help_texts = Event::Camp::CANTONS.map do |canton_short_name|
      {
        id: canton_short_name,
        url: I18n.t("events.canton_specific_help_text.#{canton_short_name}_url", default: ""),
        title: I18n.t("events.canton_specific_help_text.#{canton_short_name}_title", default: "")
      }
    end
  end

  def permitted_attrs_with_superior_and_coach_check
    attrs = entry.used_attributes.dup
    attrs += self.class.permitted_attrs

    attrs = check_superior_attrs(attrs)
    check_coach_attrs(attrs)
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

  def merge_supercamp_data
    return unless entry.is_a?(Event::Camp)
    return unless flash[:event_with_merged_supercamp]
    params[:event] ||= {}
    params[:event].merge!(flash[:event_with_merged_supercamp])
  end
end
