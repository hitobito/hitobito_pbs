# encoding: utf-8

#  Copyright (c) 2012-2013, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require Rails.root.join('db', 'seeds', 'support', 'group_seeder')


ch = Group.roots.first
srand(42)

unless ch.address.present?
  ch.update_attributes(GroupSeeder.group_attributes)
  ch.default_children.each do |child_class|
    child_class.first.update_attributes(GroupSeeder.group_attributes)
  end
end

states = Group::Kantonalverband.seed(:name, :parent_id,
  {name: 'Bern',
   short_name: 'BE',
   address: "Klostergasse 3",
   zip_code: "3333",
   town: "Bern",
   country: "Svizzera",
   email: "bern@be.ch",
   parent_id: ch.id},

  {name: 'Zürich',
   short_name: 'ZH',
   address: "Tellgasse 3",
   zip_code: "8888",
   town: "Zürich",
   country: "Svizzera",
   email: "zuerich@zh.ch",
   parent_id: ch.id },

  {name: 'Waadt',
   short_name: 'VD',
   address: "Nordostgasse 3",
   zip_code: "2000",
   town: "Lausanne",
   country: "Suisse",
   email: "vd@scout.ch",
   parent_id: ch.id }
)

states.each do |s|
  GroupSeeder.seed_social_accounts(s)
end

Group::Gremium.seed(:name, :parent_id,
  {name: 'FG Sicherheit',
   parent_id: states[0].id },

  {name: 'FG Fussball',
   parent_id: states[1].id },
)

regions = Group::Region.seed(:name, :parent_id,
  {name: 'Stadt Bern',
   parent_id: states[0].id }.merge(GroupSeeder.group_attributes),

  {name: 'Berner Oberland',
   parent_id: states[0].id }.merge(GroupSeeder.group_attributes),

  {name: 'Stadt',
   parent_id: states[1].id }.merge(GroupSeeder.group_attributes)
)

regions += Group::Region.seed(:name, :parent_id,
  {name: 'Verband Kyburg Thun',
   parent_id: regions[1].id }.merge(GroupSeeder.group_attributes)
)


regions.each do |r|
  GroupSeeder.seed_social_accounts(r)
end

abteilungen = Group::Abteilung.seed(:name, :parent_id,
  {name: 'Patria',
   parent_id: regions[0].id }.merge(GroupSeeder.group_attributes),

  {name: 'Schweizerstern',
   parent_id: regions[0].id }.merge(GroupSeeder.group_attributes),

  {name: 'Schekka',
   parent_id: regions[0].id }.merge(GroupSeeder.group_attributes),

  {name: 'Unspunne',
   parent_id: regions[1].id }.merge(GroupSeeder.group_attributes),

  {name: 'Stärn vo Buebeberg',
   parent_id: regions[1].id }.merge(GroupSeeder.group_attributes),

  {name: 'Chräis Chäib',
   parent_id: regions[2].id }.merge(GroupSeeder.group_attributes),

  {name: 'Berchtold',
   parent_id: regions[3].id }.merge(GroupSeeder.group_attributes),

  {name: 'Virus',
   parent_id: regions[3].id }.merge(GroupSeeder.group_attributes),

  {name: 'Nünenen',
   parent_id: regions[3].id }.merge(GroupSeeder.group_attributes),
)

Group::Biber.seed(:name, :parent_id,
  {name: 'Biber',
   parent_id: abteilungen[2].id}
)

woelfe = Group::Woelfe.seed(:name, :parent_id,
  {name: 'Sunnewirbu',
   parent_id: abteilungen[2].id},

  {name: 'Hathi',
   parent_id: abteilungen[2].id},

  {name: 'Aries',
   parent_id: abteilungen[6].id},

  {name: 'Castor',
   parent_id: abteilungen[6].id},
)

Group::Woelfe.seed(:name, :parent_id,
  {name: 'Rudel Akela',
   parent_id: woelfe[2].id},
  {name: 'Rudel Balu',
   parent_id: woelfe[2].id},
  {name: 'Rudel Bagira',
   parent_id: woelfe[2].id}
)

pfadis = Group::Pfadi.seed(:name, :parent_id,
  {name: 'Pegasus',
   parent_id: abteilungen[2].id},

  {name: 'Bäreried',
   parent_id: abteilungen[2].id},

  {name: 'Schloss',
   parent_id: abteilungen[6].id},
)

Group::Pfadi.seed(:name, :parent_id,
  {name: 'Fähnli Poseidon',
   parent_id: pfadis[0].id},

  {name: 'Fähnli Medusa',
   parent_id: pfadis[0].id},
)

Group::Pio.seed(:name, :parent_id,
  {name: 'Sparta',
   parent_id: abteilungen[2].id},
)

Group::Rover.seed(:name, :parent_id,
  {name: 'Rovers',
   parent_id: abteilungen[2].id},
)

Group::Elternrat.seed(:name, :parent_id,
  {name: 'Elternrat',
   parent_id: abteilungen[0].id},

  {name: 'Elternrat',
   parent_id: abteilungen[1].id},

  {name: 'Elternrat',
   parent_id: abteilungen[2].id},

  {name: 'Elternrat',
   parent_id: abteilungen[6].id},
)

Group::Gremium.seed(:name, :parent_id,
  {name: 'Fussballers',
   parent_id: abteilungen[2].id},
)

Group.rebuild!
