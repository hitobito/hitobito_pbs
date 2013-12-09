# encoding: utf-8

#  Copyright (c) 2013-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Group
  extend ActiveSupport::Concern

  included do
    # attr_accessible :bank_account

    # define global children
    children Group::Gremium

    root_types Group::Bund
  end

end
