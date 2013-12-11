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
                               )

    config.to_prepare do
      # extend application classes here
      Group.send        :include, Pbs::Group
      Person.send       :include, Pbs::Person

      GroupAbility.send :include, Pbs::GroupAbility

      Export::CsvPeople::Person.send        :include, Pbs::Export::CsvPeople::Person
      Export::CsvPeople::PeopleAddress.send :include, Pbs::Export::CsvPeople::PeopleAddress
    end

    initializer 'pbs.add_settings' do |app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    private

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end
  end
end
