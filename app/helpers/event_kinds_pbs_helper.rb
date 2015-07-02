
module EventKindsPbsHelper

  def format_event_kind_documents_text(entry)
    entry.documents_text.to_s.html_safe
  end

end
