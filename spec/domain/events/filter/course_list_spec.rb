# frozen_string_literal: true

#  Copyright (c) 2022, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Events::Filter::CourseList do
  let(:person) { people(:bulei) }
  let(:params) { {} }
  let(:entries) { Events::Filter::CourseList.new(person, params).entries }
  let(:sql) { entries.to_sql }
  let(:where_condition) { sql.sub(/.*(WHERE.*)$/, '\1') }

  it "produces a scope that does not include globally_visible" do
    expect(where_condition).to_not match("`events`.`globally_visible`")
  end
end
