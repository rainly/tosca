class ToscaRenderer < WillPaginate::LinkRenderer
  # A paginated ajaxified view needs
  # 1) a div to update : col1_content,
  # 2) a spinner : an image indicating that there's a WIP,
  # 3) Optional : a serialized form, "filters", used to keep'em with pagination
  AJAX_CALL_OPTIONS =  { :update => 'col1_content', :method => :get,
    :with => "Form.serialize(document.forms['filters'])",
    :before => "Element.show('spinner')",
    :success => "Element.hide('spinner')" }

  def create_link(text)
    options =  { :action => 'new' }
    @template.link_to @template.image_create(text), options
  end

  def page_link_or_span(page, span_class, text = nil)
    text ||= page.to_s
    classnames = Array[*span_class]

    if page and page != current_page
      if @options[:remote_url]
        ajax_call = @template.remote_function(AJAX_CALL_OPTIONS.dup.update(:url => @options[:remote_url]))
        ajax_call = "document.forms['filters'].page.value=#{page}; #{ajax_call}"
        @template.link_to_function(text, ajax_call)
      else
        @template.public_link_to text, url_for(page), :rel => rel_value(page), :class => classnames[1]
      end
    else
      @template.content_tag :span, text, :class => classnames.join(' ')
    end
  end

  def to_html
    links = @options[:page_links] ? windowed_links : []
    # previous/next buttons
    separator = @options[:separator]
    html = create_link(@options[:create_label]) << separator
    html << page_link_or_span(@collection.previous_page, %w(disabled prev_page),
                              @template.image_prev_page) << separator
    html << links.join(separator) << separator
    html << page_link_or_span(@collection.next_page, %w(disabled next_page),
                              @template.image_next_page)
    @options[:container] ? @template.content_tag(:span, html, html_attributes) : html
  end
end
