# frozen_string_literal: true

# Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
# hitobito_pbs and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https://github.com/hitobito/hitobito_pbs.

module Pbs::Export::Tabular::People::ParticipationNdsRow
  extend ActiveSupport::Concern

  included do
    alias_method_chain :first_language, :language
  end

  def first_language_with_language
    lang = entry.language.presence
    lang ? lang.upcase : "DE"
  end
end
