#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module FilterNavigation
  class Camps < Base
    def initialize(template)
      super
      init_items
    end

    def active_label
      label_for_filter(template.params.to_unsafe_h.fetch(:filter, "all"))
    end

    private

    def init_items
      filter_item("all")
      filter_item("direct")
    end

    def filter_item(name)
      item(label_for_filter(name), filter_path(name))
    end

    def label_for_filter(filter)
      template.t("filter_navigation/camps.#{filter}")
    end

    def filter_path(name)
      template.url_for(template.params.to_unsafe_h.merge(filter: name, host_only: true))
    end
  end
end
