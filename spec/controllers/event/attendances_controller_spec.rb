# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::AttendancesController do

  let(:group) { groups(:bund) }
  let(:course) { Fabricate(:course, groups: [group], kind: event_kinds(:lpk)) }

  before do
    sign_in(people(:bulei))

    @p1 = Fabricate(Event::Course::Role::Leader.name.to_sym,
                    participation: Fabricate(:event_participation,
                                             event: course, bsv_days: 5)).participation
    @p2 = Fabricate(Event::Course::Role::Helper.name.to_sym,
                    participation: Fabricate(:event_participation,
                                             event: course, bsv_days: 5)).participation
    @p3 = Fabricate(Event::Role::Speaker.name.to_sym,
                    participation: Fabricate(:event_participation,
                                             event: course, bsv_days: 5)).participation
    @p4 = Fabricate(Event::Role::Cook.name.to_sym,
                    participation: Fabricate(:event_participation,
                                             event: course, bsv_days: 5)).participation
    @p5 = Fabricate(Event::Course::Role::Participant.name.to_sym,
                    participation: Fabricate(:event_participation,
                                             event: course, bsv_days: 5)).participation
    @p6 = Fabricate(Event::Course::Role::Participant.name.to_sym,
                    participation: Fabricate(:event_participation,
                                             event: course, bsv_days: 5)).participation
  end

  context 'GET index' do

    it 'loads participants' do
      get :index, group_id: group.id, id: course.id

      expect(assigns(:leaders)).to match_array([@p1, @p2, @p3])
      expect(assigns(:cooks)).to match_array([@p4])
      expect(assigns(:participants)).to match_array([@p5, @p6])
    end

  end

  context 'PATCH update' do

    it 'updates all given bsv_days' do
      patch :update,
            group_id: group.id,
            id: course.id,
            bsv_days: {
              @p1.id.to_s => 1.5,
              @p2.id.to_s => '',
              @p4.id.to_s => 0
            }

      expect(response).to redirect_to(attendances_group_event_path(group.id, course.id))
      expect(@p1.reload.bsv_days).to eq(1.5)
      expect(@p2.reload.bsv_days).to be_nil
      expect(@p3.reload.bsv_days).to eq(5)
      expect(@p4.reload.bsv_days).to eq(0)
    end

    it 'ignores invalid values' do
      patch :update,
            group_id: group.id,
            id: course.id,
            bsv_days: {
              @p1.id.to_s => -1.5,
              @p2.id.to_s => 'jada',
              @p3.id.to_s => 6,
              @p4.id.to_s => 2.25
            }

      expect(response).to redirect_to(attendances_group_event_path(group.id, course.id))
      expect(@p1.reload.bsv_days).to eq(5)
      expect(@p2.reload.bsv_days).to eq(5)
      expect(@p3.reload.bsv_days).to eq(6)
      expect(@p4.reload.bsv_days).to eq(5)
      expect(@p5.reload.bsv_days).to eq(5)
    end

  end

end
