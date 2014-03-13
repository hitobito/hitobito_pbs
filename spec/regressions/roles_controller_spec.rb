# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe RolesController, type: :controller do

  class << self
    def it_should_set_attrs
      it 'should set params as entry attributes' do
        entry.created_at.to_date.should eq test_attrs.delete(:created_at).to_date
      end
    end
  end

  include_examples 'crud controller', skip: [%w(index), %w(show), %w(create), %w(update),  %w(destroy)]

  let(:user) { people(:bulei) }
  let(:test_entry) { roles(:al_schekka) }
  let(:test_entry_attrs) { { created_at: Date.new(2013, 8, 2) } }

end
