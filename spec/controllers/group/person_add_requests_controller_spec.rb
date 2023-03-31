# encoding: utf-8

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Group::PersonAddRequestsController do
  before { sign_in(people(:al_schekka)) }

  describe 'POST activate' do
    it 'raises' do
      expect do
        post :activate, params: { group_id: groups(:schekka).id }
      end.to raise_error /shall never get called/
    end
  end

  describe 'DELETE deactivate' do
    it 'raises' do
      expect do
        delete :deactivate, params: { group_id: groups(:schekka).id }
      end.to raise_error /shall never get called/
    end
  end
end
