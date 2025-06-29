# frozen_string_literal: true

module ApplicationHelper
  def t(*attrs, **)
    # Locale strings might include HTML tags on all keys. Variables are escaped
    # by Rails anyway.
    #
    super(attrs.join("."), **).html_safe # rubocop:disable Rails/OutputSafety
  end

  def avatar(user = nil, **options)
    user ||= current_user
    if user
      tag.span(
        class: "avatar",
        style: options[:size] ? "width: #{options[:size]}px; height: #{options[:size]}px;" : ""
      ) do
        image_tag user.gravatar_url(options).to_s,
          alt: user.name,
          class: "avatar",
          style: options[:size] ? "width: #{options[:size]}px; height: #{options[:size]}px;" : ""
      end
    else
      tag.span(
        class: "avatar",
        style: "width: #{options[:size]}px; height: #{options[:size]}px;"
      ) do
        ""
      end
    end
  end

  # These instance variables are intended here.
  # rubocop:disable Rails/HelperInstanceVariable
  def title
    return "#{@title} - #{OpenMensa::TITLE}" if @title

    OpenMensa::TITLE
  end

  def body_classes
    [
      "#{controller.controller_name}_controller",
      "#{params[:action] || 'unknown'}_action",
      @layout
    ].join(" ").strip
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def map(canteens, options = {})
    canteens = [canteens] unless canteens.respond_to?(:map)
    markers = canteens.map do |canteen|
      {
        lat: canteen.latitude,
        lng: canteen.longitude,
        title: canteen.name,
        url: canteen_path(canteen)
      }
    end

    tag.div(
      nil,
      class: "map",
      id: options[:id] || "map",
      data: {
        map: options[:id] || "map",
        markers: markers.to_json,
        hash: options[:hash]
      }
    )
  end

  def canteen_state_icon(fetch_state)
    {
      out_of_order: :"fa-solid fa-ban",
      no_fetch_ever: :"fa-solid fa-bolt",
      fetch_up_to_date: :"fa-solid fa-check",
      fetch_needed: :"fa-solid fa-triangle-exclamation"
    }[fetch_state]
  end

  def render_head_response_links
    capture do
      response.links.each do |link|
        concat content_tag(:link, nil, href: link[:url], **link[:params])
      end
    end
  end
end
