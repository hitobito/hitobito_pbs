# == Schema Information
#
# Table name: kantonalverband_cantons
#
#  id                 :integer          not null, primary key
#  kantonalverband_id :integer          not null
#  canton             :string(2)        not null
#

class KantonalverbandCanton < ActiveRecord::Base

  belongs_to :kantonalverband, class_name: 'Group::Kantonalverband'

  validates_by_schema
  validates :canton, inclusion: Cantons.short_name_strings

  def to_s
    canton.upcase
  end

end
