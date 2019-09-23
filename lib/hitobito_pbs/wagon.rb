# encoding: utf-8
# frozen_string_literal: true

#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module HitobitoPbs
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W[ #{config.root}/app/abilities
                                 #{config.root}/app/domain
                                 #{config.root}/app/jobs
                                 #{config.root}/app/serializers ]

    config.to_prepare do # rubocop:disable Metrics/BlockLength

      ### models
      Group.send        :include, Pbs::Group
      Person.send       :include, Pbs::Person
      Role.send         :include, Pbs::Role
      Event.send        :include, Pbs::Event
      Event::Kind.send  :include, Pbs::Event::Kind
      Event::Course.send :include, Pbs::Event::Course
      Event::Participation.send :include, Pbs::Event::Participation
      Event::ParticipationContactData.send :include, Pbs::Event::ParticipationContactData
      Event::Application.send :include, Pbs::Event::Application

      PeopleRelation.kind_opposites['sibling'] = 'sibling'
      PhoneNumber.send :include, Pbs::PhoneNumber

      ## domain
      Bsv::Info.leader_roles += [Event::Course::Role::Helper]
      Export::Pdf::Participation.runner = Pbs::Export::Pdf::Participation::Runner
      Event::ParticipantAssigner.send :include, Pbs::Event::ParticipantAssigner
      Event::Filter.send :include, Pbs::Event::Filter
      Export::Tabular::Events::List.send :include, Pbs::Export::Tabular::Events::List
      Export::Tabular::Events::Row.send :include, Pbs::Export::Tabular::Events::Row
      Export::Tabular::People::ParticipationsFull.send(
        :include, Pbs::Export::Tabular::People::ParticipationsFull
      )
      Export::Tabular::People::ParticipationRow.send(
        :include, Pbs::Export::Tabular::People::ParticipationRow
      )
      Export::Tabular::People::ParticipationNdbjsRow.send(
        :include, Pbs::Export::Tabular::People::ParticipationNdbjsRow
      )
      Export::Tabular::People::PersonRow.send(
        :include, Pbs::Export::Tabular::People::PersonRow
      )
      Export::Tabular::People::PeopleAddress.send(
        :include, Pbs::Export::Tabular::People::PeopleAddress
      )
      Export::Tabular::People::PeopleFull.send(
        :include, Pbs::Export::Tabular::People::PeopleFull
      )
      Export::Tabular::Events::BsvRow.send :include, Pbs::Export::Tabular::Events::BsvRow

      ### abilities
      Ability.store.register Event::ApprovalAbility
      AbilityDsl::UserContext::GROUP_PERMISSIONS << :crisis_trigger
      AbilityDsl::UserContext::LAYER_PERMISSIONS << :crisis_trigger
      GroupAbility.send :include, Pbs::GroupAbility
      PersonReadables.send :include, Pbs::PersonReadables
      PersonAbility.send :include, Pbs::PersonAbility
      EventAbility.send :include, Pbs::EventAbility
      EventAbility.send :include, Pbs::Event::Constraints
      Event::ApplicationAbility.send :include, Pbs::Event::ApplicationAbility
      Event::ApplicationAbility.send :include, Pbs::Event::Constraints
      Event::ParticipationAbility.send :include, Pbs::Event::ParticipationAbility
      Event::ParticipationAbility.send :include, Pbs::Event::Constraints
      Event::RoleAbility.send :include, Pbs::Event::Constraints
      QualificationAbility.send :include, Pbs::QualificationAbility
      VariousAbility.send :include, Pbs::VariousAbility

      ### decorators
      EventDecorator.send :include, Pbs::EventDecorator
      ContactableDecorator.send :include, Pbs::ContactableDecorator

      ### serializers
      PersonSerializer.send :include, Pbs::PersonSerializer
      GroupSerializer.send  :include, Pbs::GroupSerializer

      ### controllers
      PeopleController.permitted_attrs += [:salutation, :title, :grade_of_school, :entry_date,
                                           :leaving_date, :j_s_number, :correspondence_language,
                                           :brother_and_sisters]
      Event::KindsController.permitted_attrs += [:documents_text, :campy]
      QualificationKindsController.permitted_attrs += [:manual]

      RolesController.send :include, Pbs::RolesController
      GroupsController.send :include, Pbs::GroupsController
      PeopleController.send :include, Pbs::PeopleController
      EventsController.send :include, Pbs::EventsController
      Event::ApplicationMarketController.send :include, Pbs::Event::ApplicationMarketController
      Event::ListsController.send :include, Pbs::Event::ListsController
      Event::ParticipationsController.send :include, Pbs::Event::ParticipationsController
      QualificationsController.send :include, Pbs::QualificationsController
      Person::QueryController.search_columns << :pbs_number

      ### sheets
      Sheet::Group.send :include, Pbs::Sheet::Group
      Sheet::Event.send :include, Pbs::Sheet::Event

      ### helpers
      FilterNavigation::Events.send :include, Pbs::FilterNavigation::Events
      admin = NavigationHelper::MAIN.find { |opts| opts[:label] == :admin }
      admin[:active_for] << 'black_lists'

      ### jobs
      Event::ParticipationConfirmationJob.send :include, Pbs::Event::ParticipationConfirmationJob

      ### mailers
      Event::ParticipationMailer.send :include, Pbs::Event::ParticipationMailer
      Event::RegisterMailer.send :include, Pbs::Event::RegisterMailer
      Person::AddRequestMailer.send :include, Pbs::Person::AddRequestMailer
      Person::LoginMailer.send :include, Pbs::Person::LoginMailer

      # Main navigation
      i = NavigationHelper::MAIN.index { |opts| opts[:label] == :courses }
      NavigationHelper::MAIN.insert(
        i + 1,
        label: :camps,
        url: :list_camps_path,
        active_for: %w(list_all_camps
                       list_camps_abroad
                       list_kantonalverband_camps
                       list_camps_in_canton),
        if: lambda do |_|
          can?(:list_all, Event::Camp) ||
            can?(:list_abroad, Event::Camp) ||
            can?(:list_cantonal, Event::Camp)
        end
      )

      # rubocop:enable SingleSpaceBeforeFirstArg

      if Delayed::Job.table_exists?
        Event::CampReminderJob.new.schedule
      end

      if defined? Bullet
        Bullet.add_whitelist type: :n_plus_one_query,
                             class_name: 'Group::Kantonalverband',
                             association: :kantonalverband_cantons
      end
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
