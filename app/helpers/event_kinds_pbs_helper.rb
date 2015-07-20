# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


module EventKindsPbsHelper

  def format_event_kind_documents_text(entry)
    text = entry.documents_text
    text = text.gsub!(/\n/, '<br/>').html_safe
    auto_link(text)
  end

end
