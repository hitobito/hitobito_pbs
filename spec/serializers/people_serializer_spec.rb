#  Copyright (c) 2021, Pfadibewegung Schweiz This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe PeopleSerializer do
  let(:group) { groups(:aries) }
  let(:list) { group.people.decorate }
  let(:person) { people(:child) }
  let(:controller) { double.as_null_object }

  let(:serializer) do
    ListSerializer.new(list,
      group: group,
      multiple_groups: false,
      serializer: PeopleSerializer,
      controller: controller)
  end
  let(:service_token) { Fabricate(:service_token, layer_group_id: group.layer_group_id, people: true, permission: :layer_and_below_read) }

  let(:hash) { serializer.to_hash }

  let(:serialized_people) { hash[:people] }
  let(:linked_roles) { hash[:linked]["roles"] }

  before { Fabricate(Group::Woelfe::Wolf.name.to_sym, person: person, group: group) }

  before do
    allow_any_instance_of(PersonDecorator).to receive(:current_user).and_return(nil)
    allow_any_instance_of(PersonDecorator).to receive(:current_service_token).and_return(service_token)
  end

  it "includes roles which are not visible from above" do
    serialized_people.each do |person|
      expect(person[:links]).to have_key(:roles)
    end

    expect(linked_roles.map { |role| role[:role_class] }).to include(Group::Woelfe::Wolf.name)
  end
end
