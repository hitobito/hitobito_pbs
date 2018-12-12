module Pbs::ServiceTokensController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :authorize_class, :crisis
  end

  private

  def authorize_class_with_crisis
    authorize_class_without_crisis
  end
end
