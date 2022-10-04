# encoding: utf-8

#  Copyright (c) 2022, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe GroupDecorator do

  describe Group::Kantonalverband do
    let(:group) { groups(:be) }
    it 'Kantonalverband roles without permissions'  do
      expect(group.decorate.allowed_roles_for_self_registration).
      to eq [Group::Kantonalverband::Ehrenmitglied,
             Group::Kantonalverband::Passivmitglied,
             Group::Kantonalverband::Selbstregistriert]
    end
  end

  describe Group::Abteilung do
	let(:group) { groups(:patria) }
	  it 'Abteilung roles without permissions'  do
	    expect(group.decorate.allowed_roles_for_self_registration).
	    to eq [Group::Abteilung::Ehrenmitglied,
	           Group::Abteilung::Passivmitglied,
	           Group::Abteilung::Selbstregistriert]
    end
  end

  describe Group::Rover do
    let(:group) { groups(:rovers) }
    it 'Rover-Gruppe roles without permissions'  do
      expect(group.decorate.allowed_roles_for_self_registration).
      to eq [Group::AbteilungsRover::Rover]
    end
  end

end
