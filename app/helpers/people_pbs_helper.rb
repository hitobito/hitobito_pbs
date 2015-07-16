# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module PeoplePbsHelper

  def format_correspondence_language(person)
    lang = person.correspondence_language
    if lang
      Settings.application.languages.to_hash.with_indifferent_access[lang]
    end
  end

end
