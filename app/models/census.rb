# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Census < ActiveRecord::Base

  after_initialize :set_defaults

  validates :start_at, presence: true
  validates :start_at, :finish_at, timeliness: { type: :date, allow_blank: true }

  class << self
    # The last census defined (may be the current one)
    def last
      order('start_at DESC').first
    end

    # The currently active census
    def current
      where('start_at <= ?', Date.today).order('start_at DESC').first
    end
  end

  def to_s
    year
  end

  private

  def set_defaults
    if new_record?
      self.start_at  ||= Date.today
      self.year      ||= start_at.year
      if Settings.census
        self.finish_at ||= Date.new(year,
                                    Settings.census.default_finish_month,
                                    Settings.census.default_finish_day)
      end
    end
  end
end
