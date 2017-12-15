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
    { leiter: [Group::Abteilung::Abteilungsleitung,
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
               Group::AbteilungsRover::Einheitsleitung,
               Group::AbteilungsRover::Mitleitung,
               Group::Pta::Einheitsleitung,
               Group::Pta::Mitleitung],
      pta:    [Group::Pta::Mitglied],
      rover:  [Group::AbteilungsRover::Rover],
      pios:   [Group::Pio::Pio],
      pfadis: [Group::Pfadi::Leitpfadi,
               Group::Pfadi::Pfadi],
      woelfe: [Group::Woelfe::Leitwolf,
               Group::Woelfe::Wolf],
      biber:  [Group::Biber::Biber] }

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

    def counted_roles
      ROLE_MAPPING.values.flatten
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
    count_members(count, members.includes(:roles))
    count
  end

  # Gives back a population birthyear/age histogram. Each birthyear between
  # the ones of the youngest and oldest active members of the organization
  # is evaluated.
  def members_per_birthyear
    # pluck :birthday breaks the function because distinct is used in the query
    years = members.map(&:birthday).map { |b| b.try :year }
    year_counts = years.each_with_object(Hash.new(0)) do |year, total|
      total[year] += 1
    end
    add_relative_count complete_year_histogram(year_counts)
  end

  def exists?
    MemberCount.where(abteilung_id: abteilung.id, year: year).exists?
  end

  def kantonalverband
    @kantonalverband ||= abteilung.kantonalverband
  end

  def region
    @region ||= abteilung.parent if abteilung.parent.is_a?(Group::Region)
  end

  def members
    Person.joins(:roles).
           where(roles: { group_id: abteilung.self_and_descendants,
                          type: self.class.counted_roles.collect(&:sti_name),
                          deleted_at: nil }).
           uniq
  end

  private

  # completes the histogram by also considering years which don't appear
  # in the members list
  def complete_year_histogram(year_counts)
    return [] if year_counts.empty?
    oldest, latest = year_counts.keys.select { |y| !y.nil? }.minmax
    return nil_year_if_necessary(year_counts) if oldest.nil?
    (latest).downto(oldest).map do |year|
      OpenStruct.new(year: year, count: year_counts[year])
    end + nil_year_if_necessary(year_counts)
  end

  def nil_year_if_necessary(year_counts)
    return [] if year_counts[nil] == 0
    [OpenStruct.new(year: nil, count: year_counts[nil])]
  end

  def add_relative_count(year_histogram)
    maxcount = year_histogram.map(&:count).max
    year_histogram.each do |y|
      y.count_relative = y.count.to_f / maxcount
    end
    year_histogram
  end

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
        return person.gender == 'm' ? :"#{field}_m" : :"#{field}_f"
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
