#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Tabular::People
  class WithQualificationRow < PersonRow
    def kantonalverband_id
      entry.kantonalverband.try(:id)
    end

    def kantonalverband_name
      entry.kantonalverband.try(:name)
    end

    def roles
      entry.roles.map do |role|
        "#{role} / #{role.group.id} #{role.group.class.name.gsub("Group::", "")}"
      end.join(", ")
    end

    def find_qualification(label)
      qualifications_memo[label]
    end

    def qualifications_memo
      @qualifications_memo ||= latest_active_qualifications_by_kind.collect do |q|
        [ContactAccounts.key(q.qualification_kind.class, q.qualification_kind.label), q]
      end.to_h
    end

    def latest_active_qualifications_by_kind
      latest_active_qualifications.group_by(&:qualification_kind).values.collect(&:first)
    end

    def latest_active_qualifications
      active = entry.qualifications.select { |q| qualification_active?(q) }.compact
      active.sort do |a, b|
        next 1 unless a.finish_at
        next -1 unless b.finish_at
        b.finish_at <=> a.finish_at
      end
    end
  end
end
