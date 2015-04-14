# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe MemberCountsController do

  let(:abteilung) { groups(:schekka) }

  before { sign_in(people(:bulei)) }

  describe 'GET edit' do
    context 'in 2012' do
      before { get :edit, group_id: abteilung.id }

      it 'assigns counts' do
        expect(assigns(:member_count)).to eq(member_counts(:schekka))
        expect(assigns(:group)).to eq(abteilung)
      end
    end
  end

  describe 'PUT update' do
    context 'as mitarbeiter gs' do
      before do
        put :update, group_id: abteilung.id, member_count:
                      { leiter_f: 3, leiter_m: 1, pfadis_f: '', pfadis_m: '0' }
      end

      it { is_expected.to redirect_to(census_abteilung_group_path(abteilung, year: 2012)) }

      it 'saves counts' do
        assert_member_counts(member_counts(:schekka).reload, 3, 1, nil, 0)
      end
    end

    context 'as abteilungsleiter' do
      it 'restricts access' do
        leiter = Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym, group: abteilung).person
        sign_in(leiter)
        expect { put :update, group_id: abteilung.id, year: 2012, member_count: {} }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe 'POST create' do
    it 'handles request with redirect' do
      censuses(:two_o_12).destroy
      post :create, group_id: abteilung.id

      is_expected.to redirect_to(census_abteilung_group_path(abteilung, year: 2011))
      expect(flash[:notice]).to be_present
    end

    it 'should not change anything if counts exist' do
      expect { post :create, group_id: abteilung.id }.not_to change { MemberCount.count }
    end

    it 'should create counts' do
      Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym,
                group: abteilung,
                person: Fabricate(:person, gender: 'm', birthday: Date.new(1980, 1, 1)))
      Fabricate(Group::Pfadi::Einheitsleitung.name.to_sym,
                group: groups(:pegasus),
                person: Fabricate(:person, gender: 'w', birthday: Date.new(1982, 1, 1)))
      Fabricate(Group::Pfadi::Pfadi.name.to_sym,
                group: groups(:pegasus),
                person: Fabricate(:person, gender: 'm', birthday: Date.new(2000, 12, 31)))
      censuses(:two_o_12).destroy
      expect { post :create, group_id: abteilung.id }.to change { MemberCount.count }.by(1)

      counts = MemberCount.where(abteilung_id: abteilung.id, year: 2011)
      expect(counts.size).to eq(1)

      assert_member_counts(counts[0], 2, 1, 1, 1)
    end

    context 'as abteilungsleitung' do
      it 'creates counts' do
        censuses(:two_o_12).destroy
        leiter = Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym, group: abteilung).person
        sign_in(leiter)
        post :create, group_id: abteilung.id

        is_expected.to redirect_to(census_abteilung_group_path(abteilung, year: 2011))
        expect(flash[:notice]).to be_present
      end
    end

    context 'as guide' do
      it 'restricts access' do
        guide = Fabricate(Group::Pfadi::Einheitsleitung.name.to_sym, group: groups(:pegasus)).person
        sign_in(guide)
        expect { post :create, group_id: abteilung.id }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'removes member count' do
      expect { delete :destroy, group_id: abteilung.id }.to change { MemberCount.count }.by(-1)
    end

    it 'handles request with redirect' do
      delete :destroy, group_id: abteilung.id

      is_expected.to redirect_to(census_abteilung_group_path(abteilung, year: 2012))
      expect(flash[:notice]).to be_present
    end
  end


  def assert_member_counts(count, leiter_f, leiter_m, pfadis_f, pfadis_m)
    expect(count.leiter_f).to eq(leiter_f)
    expect(count.leiter_m).to eq(leiter_m)
    expect(count.pfadis_f).to eq(pfadis_f)
    expect(count.pfadis_m).to eq(pfadis_m)
  end

end
