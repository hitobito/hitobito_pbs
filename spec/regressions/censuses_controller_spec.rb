# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe CensusesController, type: :controller do

  render_views

  class << self
    def it_should_redirect_to_show
      it { is_expected.to redirect_to census_bund_group_path(Group.root) }
    end
  end

  include_examples 'crud controller', skip: [%w(index), %w(show), %w(edit), %w(update), %w(destroy)]

  let(:user) { people(:bulei) }
  let(:test_entry) { censuses(:two_o_12) }
  let(:test_entry_attrs) { { year: 2013, start_at: Date.new(2013, 8), finish_at: Date.new(2013, 10, 31) } }

end
