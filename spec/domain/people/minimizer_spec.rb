# frozen_string_literal: true

#
#  Copyright (c) 2023-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe People::Minimizer do
  subject { described_class.new(person).run }

  let(:person) do
    p = Fabricate(Group::Pfadi::Pfadi.sti_name.to_sym, group: groups(:pegasus)).person
    p.update!(address: "c/o Herr Blømblgårf\nBelpstrasse 37\nPostfach 42",
              address_care_of: 'c/o Herr Blømblgårf',
              street: 'Belpstrasse',
              housenumber: '37',
              postbox: 'Postfach 42',
              town: 'Bern',
              zip_code: '3007',
              title: 'Herr',
              language: 'it',
              salutation: 'lieber_vorname',
              grade_of_school: 8,
              entry_date: Date.new(2019, 5, 10),
              leaving_date: Date.new(2023, 8, 7),
              j_s_number: '756.1234.5678.97',
              nationality_j_s: 'CH',
              additional_information: 'Really like cats')
    Note.create!(author: p, text: Faker::Quote.famous_last_words, subject: p)
    Fabricate(:additional_email, contactable: p)
    Fabricate(:phone_number, contactable: p)
    Fabricate(:social_account, contactable: p)
    Fabricate(:family_member, person: p)
    p.save!
    p.reload
    p
  end

  it 'nullifies person attributes' do
    nullify_attrs.each do |attr|
      expect(person.send(attr)).to_not be_nil
    end

    subject

    person.reload

    nullify_attrs.each do |attr|
      expect(person.send(attr)).to be_nil
    end
  end

  it 'resets person language to default' do
    expect(person.language).to eq 'it'

    subject

    person.reload

    expect(person.language).to eq 'de'
  end

  it 'deletes person relations' do
    relations_to_delete.each do |attr|
      expect(person.send(attr)).to_not be_empty
    end

    subject

    person.reload

    relations_to_delete.each do |attr|
      expect(person.send(attr)).to be_empty
    end
  end

  it 'deletes taggings which are not used to exclude from mailing lists' do
    excluded_tag = Fabricate(:tag)
    SubscriptionTag.create!(excluded: true,
                            tag: excluded_tag,
                            subscription: Subscription.create!(subscriber: person,
                                                               mailing_list: Fabricate(
                                                                 :mailing_list, group: groups(:sunnewirbu)
                                                               )))
    included_tag = Fabricate(:tag)
    SubscriptionTag.create!(excluded: false,
                            tag: included_tag,
                            subscription: Subscription.create!(subscriber: person,
                                                               mailing_list: Fabricate(
                                                                 :mailing_list, group: groups(:sunnewirbu)
                                                               )))

    random_tag = Fabricate(:tag)

    person.tags = [excluded_tag, included_tag, random_tag]
    person.save!
    person.reload

    expect(person.tags).to match_array([excluded_tag, included_tag, random_tag])

    subject

    person.reload

    expect(person.tags).to_not include(included_tag)
    expect(person.tags).to_not include(random_tag)
    expect(person.tags).to match_array([excluded_tag])
  end

  def nullify_attrs
    [
      :address, # TODO: remove this when cleaning up structured addresses
      :street,
      :housenumber,
      :address_care_of,
      :postbox,
      :town,
      :zip_code,
      :title,
      :salutation,
      :grade_of_school,
      :entry_date,
      :leaving_date,
      :j_s_number,
      :nationality_j_s,
      :additional_information
    ]
  end

  def relations_to_delete
    [
      :notes,
      :additional_emails,
      :phone_numbers,
      :social_accounts,
      :family_members
    ]
  end
end
