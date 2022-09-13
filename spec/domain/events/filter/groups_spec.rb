# frozen_string_literal: true

#  Copyright (c) 2022, Pfadibewegung Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

require 'spec_helper'

describe Events::Filter::Groups do
  let(:params) { { } }

  let(:scope) { Events::FilteredList.new(person, {}, {}).base_scope.distinct }

  subject(:filter) { described_class.new(person, params, {}, scope) }

  let(:sql) { filter.to_scope.to_sql }
  let(:where_condition) { sql.sub(/.*(WHERE.*)$/, '\1') }

  let(:person) { people(:bulei) }

  context 'generally, it' do
    it 'produces a scope that does not include globally_visible' do
      expect(where_condition).to_not match('`events`.`globally_visible`')

      expect(where_condition).to_not match(
        /OR .*`events`.`globally_visible` = TRUE/
      )
    end
  end
end
