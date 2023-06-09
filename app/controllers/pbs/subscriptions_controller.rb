# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::SubscriptionsController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :render_tabular_in_background, :detail
  end

  def render_tabular_in_background_with_detail(format)
    with_async_download_cookie(format, "subscriptions_#{mailing_list.id}") do |filename|
      Export::SubscriptionsJob.new(format,
                                   current_person.id,
                                   mailing_list.id,
                                   params.slice(:household, :household_details, :selection)
                                         .merge(filename: filename)).enqueue!
    end
  end

end
