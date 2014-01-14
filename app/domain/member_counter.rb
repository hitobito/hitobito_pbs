# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class MemberCounter

  # Ordered mapping of which roles count in which field.
  # If a role from a field appearing first exists, this
  # one is counted, even if other roles exist as well.
  # E.g. Person has roles Group::Biber::Mitleitung and
  # Group::Pio::Pio => counted as :leiter
  #
  # Roles not appearing here are not counted at all.
  ROLE_MAPPING =
    { leiter: [ Group::Abteilung::Abteilungsleitung,
                Group::Abteilung::AbteilungsleitungStv,
                Group::Abteilung::StufenleitungBiber,
                Group::Abteilung::StufenleitungWoelfe,
                Group::Abteilung::StufenleitungPfadi,
                Group::Abteilung::StufenleitungPio,
                Group::Abteilung::StufenleitungRover,
                Group::Abteilung::StufenleitungPta,
                Group::Biber::Einheitsleitung,
                Group::Biber::Mitleitung,
                Group::Woelfe::Einheitsleitung,
                Group::Woelfe::Mitleitung,
                Group::Pfadi::Einheitsleitung,
                Group::Pfadi::Mitleitung,
                Group::Pio::Einheitsleitung,
                Group::Pio::Mitleitung,
                Group::Rover::Einheitsleitung,
                Group::Rover::Mitleitung,
                Group::Pta::Einheitsleitung,
                Group::Pta::Mitleitung],
      biber:  [ Group::Biber::Biber ],
      woelfe: [ Group::Woelfe::Wolf ],
      pfadis: [ Group::Pfadi::Leitpfadi,
                Group::Pfadi::Pfadi ],
      pios:   [ Group::Pio::Pio ],
      rover:  [ Group::Rover::Rover ],
      pta:    [ Group::Pta::Mitglied ] }

  attr_reader :year, :abteilung

  class << self
    def create_counts_for(abteilung)
      census = Census.current
      if census && !current_counts?(abteilung, census)
        new(census.year, abteilung).count!
        census.year
      else
        false
      end
    end

    def current_counts?(abteilung, census = Census.current)
      census && new(census.year, abteilung).exists?
    end
  end

  # create a new counter for with the given year and abteilung.
  # beware: the year is only used to store the results and does not
  # specify which roles to consider - only currently not deleted roles are counted.
  def initialize(year, abteilung)
    @year = year
    @abteilung = abteilung
  end

  def count!
    MemberCount.transaction do
      count.save!
    end
  end

  def count
    count = new_member_count
    count_members(count, members)
    count
  end

  def exists?
    MemberCount.where(abteilung_id: abteilung.id, year: year).exists?
  end

  def kantonalverband
    @kantonalverband ||= abteilung.kantonalverband
  end

  def region
    @region ||= abteilung.region
  end

  def members
    Person.joins(:roles).
           includes(:roles).
           where(roles: { group_id: abteilung.self_and_descendants, deleted_at: nil }).
           members.
           uniq
  end

  private

  def new_member_count
    count = MemberCount.new
    count.abteilung = abteilung
    count.kantonalverband = kantonalverband
    count.region = region
    count.year = year
    count
  end

  def count_members(count, people)
    people.each do |person|
      increment(count, count_field(person))
    end
  end

  def count_field(person)
    ROLE_MAPPING.each do |field, roles|
      if (person.roles.collect(&:class) & roles).present?
        return person.male? ? :"#{field}_m" : :"#{field}_f"
      end
    end
    nil
  end

  def increment(count, field)
    return unless field
    val = count.send(field)
    count.send("#{field}=", val ? val + 1 : 1)
  end

end
