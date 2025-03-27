#  Copyright (c) 2012-2025, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe PersonDecorator, :draper_with_helpers do
  include Rails.application.routes.url_helpers

  let(:person) { people(:bulei) }
  let(:other_person) { people(:al_schekka) }

  subject(:decorator) { PersonDecorator.new(person) }

  context "#siblings_in_context" do
    it "displays only roles of the group without group name" do
      FamilyMember.create!(person: person, kind: :sibling, family_key: "aaa", other: other_person)
      role_in_context = person.roles.first.dup
      role_in_context.person = other_person
      role_in_context.save!

      # add second role in same context
      other_person.roles.last.dup.save!

      expect(decorator.siblings_in_context(person.roles.first.group)).to eq [other_person]
    end
  end
end
