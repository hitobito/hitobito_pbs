# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventAbility do

  def ability(person)
    Ability.new(person.reload)
  end

  context 'event creation' do
    allowed_roles = [[:patria, 'Abteilungsleitung'],
                     [:patria, 'AbteilungsleitungStv'],
                     [:patria, 'Sekretariat'],
                     [:be, 'Kantonsleitung'],
                     [:be, 'VerantwortungAusbildung'],
                     [:be, 'Sekretariat'],
                     [:bern, 'Regionalleitung'],
                     [:bern, 'VerantwortungAusbildung'],
                     [:bern, 'Sekretariat'],
                     [:bund, 'Mitarbeiter'],
                     [:bund, 'Sekretariat']
                     # TODO in den Anforderungen sind noch: Ausbildungssekretariat / Assistenz, Ausbildung Sekretariat, welche Rollen sind das genau ?
    ]

    allowed_roles.each do |r| 
      it "#{r.second} should be allowed to create event in group #{r.first.to_s}" do
        group = groups(r.first)
        role_name = group.class.name + '::' + r.second
        person = Fabricate(role_name, group: group).person
        event = Fabricate(:event, groups: [group])
        expect(ability(person)).to be_able_to(:create, event)
      end
    end
  end

end
