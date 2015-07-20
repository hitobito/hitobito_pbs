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
                                 #{config.root}/app/serializers)

    config.to_prepare do
      # rubocop:disable SingleSpaceBeforeFirstArg

      ### models
      Group.send        :include, Pbs::Group
      Person.send       :include, Pbs::Person
      Role.send         :include, Pbs::Role
      Event::Course.send :include, Pbs::Event::Course
      Event::Participation.send :include, Pbs::Event::Participation
      Event::Application.send :include, Pbs::Event::Application
      Event::Course::Role::Participant.send :include, Pbs::Event::Course::Role::Participant

      PeopleRelation.kind_opposites['sibling'] = 'sibling'

      ## domain
      Event::ParticipationFilter.load_entries_includes += [:application]
      Export::Pdf::Participation.send :include, Pbs::Export::Pdf::Participation
      Export::Pdf::Participation.runner = Pbs::Export::Pdf::Participation::Runner

      ### abilities
      GroupAbility.send :include, Pbs::GroupAbility
      EventAbility.send :include, Pbs::EventAbility
      Event::ApplicationAbility.send :include, Pbs::Event::ApplicationAbility
      Event::ParticipationAbility.send :include, Pbs::Event::ParticipationAbility
      Event::RoleAbility.send :include, Pbs::Event::RoleAbility
      VariousAbility.send :include, Pbs::VariousAbility

      ### serializers
      PersonSerializer.send :include, Pbs::PersonSerializer
      GroupSerializer.send  :include, Pbs::GroupSerializer

      ### controllers
      PeopleController.send :include, Pbs::PeopleController
      RolesController.send :include, Pbs::RolesController
      GroupsController.send :include, Pbs::GroupsController
      EventsController.send :include, Pbs::EventsController

      Event::ApplicationsController.send :include, Pbs::Event::ApplicationsController
      Event::ParticipationsController.send :include, Pbs::Event::ParticipationsController
      Event::ApplicationMarketController.send :include, Pbs::Event::ApplicationMarketController

      Event::KindsController.permitted_attrs += [:documents_text]

      ### exports
      Export::Csv::People::PersonRow.send     :include, Pbs::Export::Csv::People::PersonRow
      Export::Csv::People::PeopleAddress.send :include, Pbs::Export::Csv::People::PeopleAddress
      Export::Csv::People::PeopleFull.send    :include, Pbs::Export::Csv::People::PeopleFull

      ### decorators
      Event::ParticipationDecorator.send :include, Pbs::Event::ParticipationDecorator

      ### sheets
      Sheet::Group.send :include, Pbs::Sheet::Group
      Sheet::Event.send :include, Pbs::Sheet::Event

      ### jobs
      Event::ParticipationConfirmationJob.send :include, Pbs::Event::ParticipationConfirmationJob

      ### mailers
      Event::ParticipationMailer.send :include, Pbs::Event::ParticipationMailer

      # rubocop:enable SingleSpaceBeforeFirstArg
    end

    initializer 'pbs.add_settings' do |_app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    initializer 'jubla.add_inflections' do |_app|
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
