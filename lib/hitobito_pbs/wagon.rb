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
      Event.send        :include, Pbs::Event
      Event::Course.send :include, Pbs::Event::Course
      Event::Participation.send :include, Pbs::Event::Participation
      Event::Application.send :include, Pbs::Event::Application

      PeopleRelation.kind_opposites['sibling'] = 'sibling'

      ## domain
      Bsv::Info.leader_roles += [Event::Course::Role::Helper]
      Export::Pdf::Participation.runner = Pbs::Export::Pdf::Participation::Runner
      Event::ParticipantAssigner.send :include, Pbs::Event::ParticipantAssigner
      Export::Csv::Events::List.send :include, Pbs::Export::Csv::Events::List
      Export::Csv::Events::Row.send :include, Pbs::Export::Csv::Events::Row
      Export::Csv::People::ParticipationNdbjsRow.send(
        :include, Pbs::Export::Csv::People::ParticipationNdbjsRow)
      Export::Csv::Events::BsvList.send :include, Pbs::Export::Csv::Events::BsvList
      Export::Csv::Events::BsvRow.send :include, Pbs::Export::Csv::Events::BsvRow

      ### abilities
      GroupAbility.send :include, Pbs::GroupAbility
      EventAbility.send :include, Pbs::EventAbility
      EventAbility.send :include, Pbs::Event::Constraints
      Event::ApplicationAbility.send :include, Pbs::Event::ApplicationAbility
      Event::ApplicationAbility.send :include, Pbs::Event::Constraints
      Event::ParticipationAbility.send :include, Pbs::Event::ParticipationAbility
      Event::ParticipationAbility.send :include, Pbs::Event::Constraints
      Event::RoleAbility.send :include, Pbs::Event::Constraints
      VariousAbility.send :include, Pbs::VariousAbility

      ### serializers
      PersonSerializer.send :include, Pbs::PersonSerializer
      GroupSerializer.send  :include, Pbs::GroupSerializer

      ### controllers
      PeopleController.permitted_attrs += [:salutation, :title, :grade_of_school, :entry_date,
                                           :leaving_date, :j_s_number, :correspondence_language,
                                           :brother_and_sisters]
      Event::KindsController.permitted_attrs += [:documents_text]

      RolesController.send :include, Pbs::RolesController
      GroupsController.send :include, Pbs::GroupsController
      EventsController.send :include, Pbs::EventsController
      Event::ApplicationsController.send :include, Pbs::Event::ApplicationsController
      Event::ApplicationMarketController.send :include, Pbs::Event::ApplicationMarketController
      Event::ParticipationsController.send :include, Pbs::Event::ParticipationsController

      ### exports
      Export::Csv::People::PersonRow.send     :include, Pbs::Export::Csv::People::PersonRow
      Export::Csv::People::PeopleAddress.send :include, Pbs::Export::Csv::People::PeopleAddress
      Export::Csv::People::PeopleFull.send    :include, Pbs::Export::Csv::People::PeopleFull

      ### sheets
      Sheet::Group.send :include, Pbs::Sheet::Group

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

    initializer 'pbs.add_inflections' do |_app|
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
