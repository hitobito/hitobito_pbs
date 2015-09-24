# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe QualificationsController do

  before { sign_in(people(:bulei)) }

  let(:non_manual) { Fabricate(:qualification_kind, manual: false) }
  let(:person) { people(:al_schekka) }

  before { non_manual }

  it 'contains only manual' do
    get :new, group_id: groups(:schekka).id, person_id: person.id
    expect(assigns(:qualification_kinds)).not_to include(non_manual)
  end

  it 'can create manual qualification kind' do
    expect do
      post :create,
           group_id: groups(:schekka).id,
           person_id: person.id,
           qualification: { qualification_kind_id: qualification_kinds(:alpk).id,
                            start_at: Time.zone.today }
    end.to change { Qualification.count }.by(1)
  end

  it 'cannot create non-manual qualification kind' do
    expect do
      post :create,
           group_id: groups(:schekka).id,
           person_id: person.id,
           qualification: { qualification_kind_id: non_manual.id,
                            start_at: Time.zone.today }
    end.to raise_error(CanCan::AccessDenied)
  end

  it 'can destroy manual qualification kind' do
    quali = Fabricate(:qualification, qualification_kind: qualification_kinds(:alpk), person: person)
    expect do
      delete :destroy,
             group_id: groups(:schekka).id,
             person_id: person.id,
             id: quali.id
    end.to change { Qualification.count }.by(-1)
  end

  it 'cannot destroy non-manual qualification kind' do
    quali = Fabricate(:qualification, qualification_kind: non_manual, person: person)
    expect do
      delete :destroy,
             group_id: groups(:schekka).id,
             person_id: person.id,
             id: quali.id
    end.to raise_error(CanCan::AccessDenied)
  end
end
