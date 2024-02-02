# frozen_string_literal: true

#  Copyright (c) 2017-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

SeedFu.quiet = true
SeedFu.seed [
  Rails.root.join('db', 'seeds'),
  HitobitoPbs::Wagon.root.join('db', 'seeds'),
]
