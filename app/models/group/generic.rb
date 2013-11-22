module Group::Generic
  extend ActiveSupport::Concern

  included do
    root_types Group::TopLayer
  end
end
