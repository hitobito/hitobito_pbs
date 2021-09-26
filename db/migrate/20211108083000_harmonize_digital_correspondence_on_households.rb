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

    def people_without_household
      @people_scope.where(household_key: nil)
    end

    def grouped_households
      people = Person.quoted_table_name

      # remove previously added selects, very important to make this query scale
      @people_scope.unscope(:select, :includes).select( # group by household, but keep NULLs separate
        "IFNULL(#{people}.`household_key`, #{people}.`id`) as `key`"
      )
        .select("MIN(#{Person.quoted_table_name}.`id`) as `id`") # Must select the primary key column because find_in_batches needs it for sorting.
        .select("COUNT(#{people}.`household_key`) as `count`")
        .group(:key)
    end

    def households_in_batches
      base_scope = only_households

      # When limiting the number of rows, make sure to always show some households.
      # For this, we override the order that find_in_batches uses. By default, it
      # always orders by the primary key column ascendingly.
      def base_scope.batch_order
        [Arel::Nodes::SqlLiteral.new("`count`").desc, super]
      end

      base_scope.find_in_batches(batch_size: 300) do |batch|
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

    def each(exclude_non_households: false, &block)
      return to_enum(:each) unless block

      households_in_batches(
        exclude_non_households: exclude_non_households
      ) { |batch| batch.each(&block) }
    end

    private

    def only_households
      grouped_households.where.not(household_key: nil)
    end

    def fetch_people_with_id_or_household_key(keys_or_ids)
      # Search for any number of housemates, regardless of preview limit
      base_scope = @people_scope.unscope(:limit) # Make sure to select household_key if we aren't selecting specific columns
      if base_scope.select_values.present?
        base_scope = base_scope.select(:household_key)
      end

      base_scope.where(household_key: keys_or_ids).or(
        base_scope.where(id: keys_or_ids)
      )
        .load
    end
  end
end
