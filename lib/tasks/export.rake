#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

namespace :export do
  desc 'Export member_counts for year - default is current year'
  task :member_counts, [:year] => [:environment] do |_, args|
    args.with_defaults(year: Time.zone.now.year)

    list = MemberCount.where(year: args.year)
    csv = Export::Tabular::MemberCounts::List.export(:csv, list)
    File.write("member_counts_#{args.year}.csv", csv)
  end

  desc 'Export people with their qualifications'
  task :people_with_qualifications, [:limit] => [:environment] do |_, args|
    list = Person.includes(:primary_group, roles: :group, qualifications: :qualification_kind)
    list = list.limit(args.limit) if args.limit
    csv = Export::Tabular::People::WithQualifications.export(:csv, list)
    File.write('people_with_qualifications.csv', csv)
  end
end
