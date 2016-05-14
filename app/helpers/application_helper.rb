module ApplicationHelper
  def menu_item_link(text, path, options = {})
    content_tag :li, class: (request.path == path ? :active : nil) do
      link_to text, path, options
    end
  end
end
