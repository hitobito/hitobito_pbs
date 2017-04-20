# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe PeopleController do

  context 'as top leader' do

    let(:al) { people(:al_berchtold) }
    let(:berchtold) { groups(:berchtold) }
    let(:schekka) { groups(:schekka) }

    before { sign_in(people(:bulei)) }

    describe 'PUT #primary_group' do

      it 'resets kantonalverband when changing primary group' do

        al.update!({kantonalverband: nil})
        Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym, group: schekka, person: al)

        put :primary_group, group_id: berchtold, id: al.id, primary_group_id: schekka.id, format: :js

        expect(al.reload.primary_group_id).to eq(schekka.id)
        expect(al.kantonalverband_id).to eq(groups(:be).id)
        is_expected.to render_template('primary_group')

      end
    end

  end

end
