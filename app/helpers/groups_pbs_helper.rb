module GroupsPbsHelper

  def format_group_website(group)
    if group.website?
      url = group.website.start_with?('http') ? group.website : "http://#{group.website}"
      link_to(group.website, url, target: :blank)
    end
  end

end