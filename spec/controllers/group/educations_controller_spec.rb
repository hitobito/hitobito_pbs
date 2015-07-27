# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Group::EducationsController do

  render_views

  let(:person) { people(:bulei) }

  before { sign_in(person) }

  def create_qualification(attrs)
    Qualification.create!(attrs.merge(qualification_kind: qualification_kinds(:alpk), person: person))
  end

  it 'does list leader participations' do
    get :index, id: groups(:bund).id
    expect(response.body).to have_content 'Dr. Bundes Leiter / Scout'
    expect(response.body).to have_content 'Top Course'
  end

  it 'does list participant participations' do
    get :index, id: groups(:schekka).id
    expect(response.body).to have_content 'Schekka AL'
    expect(response.body).to have_content 'Top Course'
  end

  it 'does not list completed events' do
    events(:top_course).update!(state: 'completed')
    get :index, id: groups(:bund).id
    expect(response.body).not_to have_content 'Top Course'
  end

  it 'lists qualifications' do
    create_qualification(start_at: Date.yesterday)
    get :index, id: groups(:bund).id
    expect(response.body).to have_content 'Experte'
  end

  it 'lists qualifications event when expired' do
    create_qualification(start_at: Date.today - 3.days, finish_at: Date.yesterday)
    get :index, id: groups(:bund).id
    expect(response.body).to have_content 'Experte'
  end

  it 'raises AccessDenied if not permitted' do
    sign_in(people(:al_schekka))
    expect { get :index, id: groups(:bund).id }.to raise_error CanCan::AccessDenied
  end

end
