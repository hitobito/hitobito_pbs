#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class HarmonizeDigitalCorrespondenceOnHouseholds < ActiveRecord::Migration[6.0]
  FLAG = :prefers_digital_correspondence

  def up
    Person.reset_column_information

    MyHouseholdList.new(Person.all).households_in_batches do |households|
      households.map { |people| harmonize_flag(people) }
    end
  end

  def harmonize_flag(people)
    return unless flags_differ?(people)

    # Null is not allowed for the flag, so someone in the household must have the flag set to true.
    # The household shall receive digital correspondence.
    Person.where(id: people.map(&:id)).update_all(FLAG => true)
  end

  def flags_differ?(people)
    people.map { |p| p.send(FLAG) }.uniq.count > 1
  end

  # A stripped copy of `People::HouseholdList` for use in this migration
  class MyHouseholdList
    include Enumerable

    def initialize(people_scope)
      @people_scope = people_scope
    end

    def grouped_households
      people = Person.quoted_table_name

      @people_scope.
        # remove previously added selects, very important to make this query scale
        unscope(:select, :includes).
        # group by household, but keep NULLs separate
        select("IFNULL(#{people}.`household_key`, #{people}.`id`) as `key`").
        group(:key).
        # Primary sorting criterion
        select("COUNT(#{people}.`household_key`) as `member_count`").
        # Secondary, unique sorting criterion
        select("MIN(#{people}.`id`) as `id`")
    end

    def households_in_batches
      in_batches(only_households, batch_size: 300) do |batch|
        involved_people =
          fetch_people_with_id_or_household_key(batch.map(&:key))
        grouped_people =
          batch.map do |household|
            involved_people.select do |person|
              # the 'key' is either a household key or a single person id
              person.household_key ==
                household.key ||
                person.id.to_s == household.key
            end
          end
        yield grouped_people
      end
    end

    private

    def only_households
      grouped_households.where.not(household_key: nil)
    end

    # Copied and adapted from ActiveRecord::Batches#in_batches
    # We need to order and "offset" the batches by two separate columns, which
    # activerecord doesn't support natively. Activerecord only supports ordering by the
    # primary key column and doesn't use SQL OFFSET internally, for performance reasons:
    def in_batches(base_scope, batch_size: 1000)
      relation = base_scope

      batch_limit = batch_size
      if base_scope.limit_value
        remaining   = base_scope.limit_value
        batch_limit = remaining if remaining < batch_limit
      end

      relation = relation.reorder('`member_count` DESC, id ASC').limit(batch_limit)
      # Retaining the results in the query cache would undermine the point of batching
      relation.skip_query_cache!
      batch_relation = relation

      loop do
        records = batch_relation.records
        ids = records.map(&:id)
        yielded_relation = base_scope.where(id: ids)
        yielded_relation.send(:load_records, records)

        break if ids.empty?

        member_count_offset = records.last.member_count
        id_offset = ids.last

        yield yielded_relation

        break if ids.length < batch_limit

        if base_scope.limit_value
          remaining -= ids.length

          if remaining == 0
            # Saves a useless iteration when the limit is a multiple of the batch size.
            break
          elsif remaining < batch_limit
            relation = relation.limit(remaining)
          end
        end

        batch_relation = relation.having('`member_count` < ? OR (`member_count` = ? AND `id` > ?)',
                                        member_count_offset, member_count_offset, id_offset)
      end
    end

    def fetch_people_with_id_or_household_key(keys_or_ids)
      # Search for any number of housemates, regardless of preview limit
      base_scope = @people_scope.unscope(:limit)
      # Make sure to select household_key if we aren't selecting specific columns
      base_scope = base_scope.select(:household_key) if base_scope.select_values.present?

      base_scope.where(household_key: keys_or_ids).or(
        base_scope.where(id: keys_or_ids)
      )
        .load
    end
  end
end
