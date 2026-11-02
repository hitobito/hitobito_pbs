#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Pbs::PersonSerializer do
  let(:person) { people(:al_schekka).decorate }
  let(:controller) { double.as_null_object }

  let(:serializer) { PersonSerializer.new(person, controller: controller) }
  let(:hash) { serializer.to_hash }

  subject { hash[:people].first }

  before do
    allow(controller).to receive(:can?).and_return(true)
    allow_any_instance_of(PersonDecorator).to receive(:current_user).and_return(people(:bulei))
  end

  it "serializes pbs number" do
    expect(subject[:pbs_number]).to be_present.and eq(person.pbs_number)
  end
end
