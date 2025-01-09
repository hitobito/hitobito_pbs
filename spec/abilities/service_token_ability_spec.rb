#  Copyright (c) 2012-2020, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe ServiceTokenAbility do
  let(:user) { role.person }
  let(:group) { role.group }
  let(:service_token) { Fabricate(:service_token, layer: group) }

  subject { Ability.new(user.reload) }

  context "restricted roles" do
    restricted_roles = [
      "MitarbeiterGs",
      "Adressverwaltung",
      "AssistenzAusbildung",
      "PowerUser",
      "LeitungKernaufgabeAusbildung",
      "Sekretariat"
    ]

    restricted_roles.each do |r|
      context r.to_s do
        let(:role) { Fabricate("Group::Bund::" + r, group: groups(:bund)) }

        it "may not create service token in bund" do
          is_expected.not_to be_able_to(:create, group.service_tokens.new)
        end

        %i[update show edit destroy].each do |action|
          it "may not #{action} service tokens in bund" do
            is_expected.not_to be_able_to(action, service_token)
          end
        end
      end
    end
  end

  context "ItSupport is not restricted" do
    let(:role) { Fabricate(Group::Bund::ItSupport.name.to_sym, group: groups(:bund)) }

    it "may create service token in bund" do
      is_expected.to be_able_to(:create, group.service_tokens.new)
    end

    %i[update show edit destroy].each do |action|
      it "may #{action} service tokens in bund" do
        is_expected.to be_able_to(action, service_token)
      end
    end
  end
end
