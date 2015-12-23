# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe 'Dropdown::Event::CampParticipantStatus' do

  include FormatHelper
  include I18nHelper
  include LayoutHelper
  include UtilityHelper

  let(:group) { event.groups.first }
  let(:event) { events(:schekka_camp) }
  let(:participation) { Fabricate(:pbs_participation, event: event) }
  let(:dropdown) { Dropdown::Event::CampParticipantStatus.new(self, group, event, participation) }

  subject { dropdown.to_s }

  def link_to(label, path, options = {})
    "<a href='#{path}'>#{label}</a>"
  end

  def can?(*args)
    true
  end

  it 'renders dropdown without paper application' do
    is_expected.to have_content 'Status ändern'
    is_expected.to have_selector 'ul.dropdown-menu'
    is_expected.to have_selector 'a' do |tag|
      expect(tag).to have_selector 'strong' do |label|
        expect(label).to have_content 'Zugewiesen'
      end
    end
    is_expected.to have_selector 'a' do |tag|
      expect(tag).to have_content 'Abgemeldet'
    end
    is_expected.to have_selector 'a' do |tag|
      expect(tag).to have_content 'Nicht erschienen'
    end
    is_expected.not_to have_content 'Elektronisch angemeldet'
  end

  it 'renders dropdown with paper application' do
    event.update!(paper_application_required: true)
    is_expected.to have_selector 'a' do |tag|
      expect(tag).to have_content 'Elektronisch angemeldet'
    end
  end
end
