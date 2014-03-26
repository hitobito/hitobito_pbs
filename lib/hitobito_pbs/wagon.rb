# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module HitobitoPbs
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    # config.autoload_paths += %W( #{config.root}/lib )

    # Add a load path for this specific wagon
    config.autoload_paths += %W( #{config.root}/app/abilities
                                 #{config.root}/app/domain
                                 #{config.root}/app/jobs
                               )

    config.to_prepare do
      # extend application classes here
      Group.send        :include, Pbs::Group
      Person.send       :include, Pbs::Person
      Role.send         :include, Pbs::Role

      GroupAbility.send   :include, Pbs::GroupAbility
      VariousAbility.send :include, Pbs::VariousAbility

      PeopleController.permitted_attrs +=
        [:salutation, :title, :grade_of_school, :entry_date, :leaving_date,
         :j_s_number, :correspondence_language, :brother_and_sisters]
      RolesController.send :include, Pbs::RolesController

      Export::Csv::People::PersonRow.send     :include, Pbs::Export::Csv::People::PersonRow
      Export::Csv::People::PeopleAddress.send :include, Pbs::Export::Csv::People::PeopleAddress
      Export::Csv::People::PeopleFull.send    :include, Pbs::Export::Csv::People::PeopleFull
    end

    initializer 'pbs.add_settings' do |app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    initializer 'jubla.add_inflections' do |app|
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.irregular 'census', 'censuses'
      end
    end

    private

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end
  end
end
