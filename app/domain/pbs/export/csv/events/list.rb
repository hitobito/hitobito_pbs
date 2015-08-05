# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Export::Csv::Events::List
  extend ActiveSupport::Concern

  included do
    alias_method_chain :add_contact_labels, :advisor
    alias_method_chain :add_additional_labels, :pbs
    alias_method_chain :translated_prefix, :advisor
  end

  private

  def add_additional_labels_with_pbs(labels)
    add_additional_labels_without_pbs(labels)

    add_used_attribute_label(labels, :express_fee)
    add_used_attribute_label(labels, :language_de)
    add_used_attribute_label(labels, :language_fr)
    add_used_attribute_label(labels, :language_it)
    add_used_attribute_label(labels, :language_en)
  end

  def add_contact_labels_with_advisor(labels)
    add_contact_labels_without_advisor(labels)
    if attr_used?(:advisor_id)
      add_prefixed_contactable_labels(labels, :advisor)
    end
  end

  def translated_prefix_with_advisor(prefix)
    prefix == :advisor ?  human_attribute(:advisor) : translated_prefix_without_advisor(prefix)
  end

end
