# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

Group::Root.seed_once(:parent_id,
                      { name: 'Root' })

Group::Bund.seed_once(:parent_id,
                      { name: 'Pfadibewegung Schweiz',
                        short_name: 'PBS', parent_id: Group.roots.first.id })
Group::Silverscouts.seed_once(:parent_id,
                              { name: 'Silverscouts Schweiz',
                                short_name: 'SILV', parent_id: Group.roots.first.id })
