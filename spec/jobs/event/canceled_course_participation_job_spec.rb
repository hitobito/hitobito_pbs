# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::CanceledCourseParticipationJob do

  let(:event) { participation.event }
  let(:job) { Event::CanceledCourseParticipationJob.new(participation) }
  let(:participation) { event_participations(:top_participant) }

  let(:recipients) { job.send(:recipients) }

  context 'recipients' do

    it 'contains abteilungsleitung and kursleitung' do
      expect(recipients).to match_array(people(:al_schekka, :bulei))
    end

    context 'with organizers' do

      before do
        @bund = Fabricate(Group::Bund::Geschaeftsleitung.name.to_sym, group: groups(:bund)).person
        @organizer1 = Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)).person
        @organizer2 = Fabricate(Group::Kantonalverband::VerantwortungAusbildung.name.to_sym, group: groups(:be)).person
        @eduction_be = Fabricate(Group::Region::VerantwortungAusbildung.name.to_sym, group: groups(:bern)).person

        participation.update!(person: Fabricate(Group::Region::Redaktor.name.to_sym, group: groups(:bern)).person)
      end

      it 'contains and kursleitung and organizer' do
        expect(recipients).to match_array([people(:bulei), @organizer1, @organizer2])
      end
    end
  end

end
