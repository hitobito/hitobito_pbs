# encoding: utf-8

#  Copyright (c) 2012-2013, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Group
  extend ActiveSupport::Concern

  included do
    attr_accessible :website, :bank_account, :description

    attr_accessible(*(accessible_attributes.to_a + [:pbs_shortname]),
                    as: :superior)


    validates :description, length: { allow_nil: true, maximum: 2 ** 16 - 1 }

    # define global children
    children Group::Gremium

    root_types Group::Bund
  end

end
