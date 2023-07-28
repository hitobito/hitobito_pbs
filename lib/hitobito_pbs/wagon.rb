# frozen_string_literal: true

#  Copyright (c) 2012-2021, Pfadibewegung Schweiz. This file is part of
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
      Group.include Pbs::Group
      Person.include Pbs::Person
      Role.include Pbs::Role
      Qualification.include Pbs::Qualification
      Event.include Pbs::Event
      Event::Kind.include Pbs::Event::Kind
      Event::Course.include Pbs::Event::Course
      Event::Participation.include Pbs::Event::Participation
      Event::ParticipationContactData.include Pbs::Event::ParticipationContactData
      Event::Application.include Pbs::Event::Application
      Event::Role.include Pbs::Event::Role
      Event::Role::Cook.include Pbs::Event::Role::Cook
      MailingList.include Pbs::MailingList
      ServiceToken.include Pbs::ServiceToken

      Event.acts_as_nested_set(dependent: :nullify)

      PeopleRelation.kind_opposites['sibling'] = 'sibling'
      PhoneNumber.include Pbs::PhoneNumber

      Event::Role::Speaker.qualifiable = true # According to https://github.com/hitobito/hitobito_pbs/issues/233

      ## domain
      Bsv::Info.leader_roles += [Event::Course::Role::Helper]
      Export::Pdf::Participation.runner = Pbs::Export::Pdf::Participation::Runner
      Event::ParticipantAssigner.include Pbs::Event::ParticipantAssigner
      Event::Filter.include Pbs::Event::Filter
      Events::Filter::Groups.include Pbs::Events::Filter::Groups
      Event::Qualifier.include Pbs::Event::Qualifier
      Export::Tabular::Events::List.include Pbs::Export::Tabular::Events::List
      Export::Tabular::Events::Row.include Pbs::Export::Tabular::Events::Row
      Export::Tabular::People::ParticipationsFull.include(
        Pbs::Export::Tabular::People::ParticipationsFull
      )
      Export::Tabular::People::ParticipationRow.include(
        Pbs::Export::Tabular::People::ParticipationRow
      )
      Export::Tabular::People::ParticipationNdsRow.include(
        Pbs::Export::Tabular::People::ParticipationNdsRow
      )
      Export::Tabular::People::PersonRow.include Pbs::Export::Tabular::People::PersonRow
      Export::Tabular::People::PeopleAddress.include Pbs::Export::Tabular::People::PeopleAddress
      Export::Tabular::People::PeopleFull.include Pbs::Export::Tabular::People::PeopleFull
      Export::Tabular::Events::BsvRow.include Pbs::Export::Tabular::Events::BsvRow
      Export::PeopleExportJob.include Pbs::Export::PeopleExportJob
      Export::EventParticipationsExportJob.prepend Pbs::Export::EventParticipationsExportJob
      Export::SubscriptionsJob.include Pbs::Export::SubscriptionsJob

      Person::AddRequest::Approver::Event.prepend(
        Pbs::Person::AddRequest::Approver::Event
      )

      Salutation.prepend Pbs::Salutation

      ### abilities
      Ability.store.register Event::ApprovalAbility
      AbilityDsl::UserContext::GROUP_PERMISSIONS << :crisis_trigger
      AbilityDsl::UserContext::LAYER_PERMISSIONS << :crisis_trigger
      GroupAbility.include Pbs::GroupAbility
      GroupAbility.prepend Pbs::ServiceToken::Constraints
      PersonReadables.include Pbs::PersonReadables
      PersonAbility.include Pbs::PersonAbility
      EventAbility.include Pbs::EventAbility
      EventAbility.include Pbs::Event::Constraints
      Event::ApplicationAbility.include Pbs::Event::ApplicationAbility
      Event::ApplicationAbility.include Pbs::Event::Constraints
      Event::ParticipationAbility.include Pbs::Event::ParticipationAbility
      Event::ParticipationAbility.include Pbs::Event::Constraints
      Event::RoleAbility.include Pbs::Event::Constraints
      QualificationAbility.include Pbs::QualificationAbility
      ServiceTokenAbility.prepend Pbs::ServiceToken::Constraints
      TokenAbility.include Pbs::TokenAbility
      VariousAbility.include Pbs::VariousAbility

      ### decorators
      EventDecorator.icons['Event::Camp'] = :campground
      EventDecorator.include Pbs::EventDecorator
      GroupDecorator.include Pbs::GroupDecorator
      PersonDecorator.include Pbs::PersonDecorator
      ContactableDecorator.include Pbs::ContactableDecorator
      Event::ParticipationDecorator.include Pbs::Event::ParticipationDecorator
      GroupDecorator.include Pbs::GroupDecorator
      ServiceTokenDecorator.kinds += [:group_health]

      ### serializers
      PersonSerializer.include Pbs::PersonSerializer
      GroupSerializer.include Pbs::GroupSerializer
      EventSerializer.include Pbs::EventSerializer
      EventParticipationSerializer.include Pbs::EventParticipationSerializer

      ### controllers
      PeopleController.permitted_attrs += [:salutation, :title, :grade_of_school, :entry_date,
                                           :leaving_date, :j_s_number, :correspondence_language,
                                           :prefers_digital_correspondence, :brother_and_sisters]
      Event::KindsController.permitted_attrs += [:documents_text, :campy, :can_have_confirmations,
                                                 :confirmation_name]
      QualificationKindsController.permitted_attrs += [:manual]
      ServiceTokensController.permitted_attrs += [:group_health, :census_evaluations]

      Group::PersonAddRequestsController.prepend Pbs::Group::PersonAddRequestsController
      GroupsController.include Pbs::GroupsController
      Person::HouseholdsController.include Pbs::Person::HouseholdsController
      PeopleController.include Pbs::PeopleController
      EventsController.include Pbs::EventsController
      Event::ApplicationMarketController.include Pbs::Event::ApplicationMarketController
      Event::ListsController.include Pbs::Event::ListsController
      Event::ParticipationsController.include Pbs::Event::ParticipationsController
      Event::QualificationsController.include Pbs::Event::QualificationsController
      Event::RolesController.prepend Pbs::Event::RolesController
      QualificationsController.include Pbs::QualificationsController
      Person::QueryController.search_columns << :pbs_number
      SubscriptionsController.include Pbs::SubscriptionsController

      ### sheets
      Sheet::Group.include Pbs::Sheet::Group
      Sheet::Event.include Pbs::Sheet::Event

      ### helpers
      EventsHelper.include Pbs::EventsHelper
      FilterNavigation::Events.include Pbs::FilterNavigation::Events
      admin = NavigationHelper::MAIN.find { |opts| opts[:label] == :admin }
      admin[:active_for] << 'black_lists'
      ContactAttrs::ControlBuilder.include Pbs::ContactAttrs::ControlBuilder
      Dropdown::PeopleExport.include Pbs::Dropdown::PeopleExport

      ### jobs
      Event::ParticipationConfirmationJob.include Pbs::Event::ParticipationConfirmationJob

      ### mailers
      Event::ParticipationMailer.include Pbs::Event::ParticipationMailer
      Event::RegisterMailer.include Pbs::Event::RegisterMailer
      Person::AddRequestMailer.include Pbs::Person::AddRequestMailer
      Person::LoginMailer.include Pbs::Person::LoginMailer

      # Main navigation
      i = NavigationHelper::MAIN.index { |opts| opts[:label] == :courses }
      NavigationHelper::MAIN.insert(
        i + 1,
        label: :camps,
        icon_name: :campground,
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
      index_admin = NavigationHelper::MAIN.index { |opts| opts[:label] == :admin }
      NavigationHelper::MAIN.insert(
        index_admin,
        label: :help,
        icon_name: :'info-circle',
        url: :help_path
      )

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
