class CensusEvaluation

  attr_reader :year, :group, :sub_group_type

  # Group may be one of the referenced group types in MemberCount.
  def initialize(year, group, sub_group_type)
    @year = year
    @group = group
    @sub_group_type = sub_group_type
  end

  # In years before the current census, the sub groups are only
  # determined by existing member counts.
  # Otherwise, the current descendants are used.
  def sub_groups
    if sub_group_type
      scope = sub_groups_locked? ? sub_groups_with_counts : current_census_sub_groups
      scope.order(:name)
    end
  end

  def counts_by_sub_group
    if sub_group_type
      sub_group_field = :"#{sub_group_type.model_name.element}_id"
      group.census_groups(year).inject({}) do |hash, count|
        hash[count.send(sub_group_field)] = count
        hash
      end
    end
  end

  def total
    group.census_total(year)
  end

  def census
    @census ||= Census.where(year: year).first
  end

  def current_census
    @current_census ||= Census.current
  end

  # Is the displayed census the current one?
  def census_current?
    current_census == census
  end

  # Is the displayed census the current or a future one?
  def census_current_or_future?
    census && (census.year >= Date.today.year || census_current?)
  end

  # Is the displayed year the year of the current census?
  def current_census_year?
    current_census && year == current_census.year
  end

  private

  def sub_groups_locked?
    locked = current_census && year < current_census.year
  end

  def sub_groups_with_counts
    Group.where(id: group.member_counts.where(year: year).
                                        select(sub_group_id_col).
                                        uniq)
  end

  def current_census_sub_groups
    sub_group_ids = current_sub_groups.pluck(:id)
    sub_group_ids -= sub_group_ids_with_other_group_count(sub_group_ids) unless group.class == Group::Bund
    sub_group_ids += sub_groups_with_counts.pluck(:id)
    Group.where(id: sub_group_ids.uniq)
  end

  def current_sub_groups
    group.descendants.where(type: sub_group_type.sti_name).without_deleted
  end

  def sub_group_ids_with_other_group_count(sub_group_ids)
    MemberCount.where(sub_group_id_col => sub_group_ids,
                      :year => year).
                where("#{group_id_col} <> ?", group.id).
                pluck(sub_group_id_col)
  end

  def sub_group_id_col
    "#{sub_group_type.model_name.element}_id"
  end

  def group_id_col
    "#{group.class.model_name.element}_id"
  end

end