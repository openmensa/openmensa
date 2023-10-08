# frozen_string_literal: true

module ApplicationHelper
  def t(*attrs)
    options = attrs.extract_options!
    id      = attrs.join "."

    options[:default] ||= "[[#{id}]]"

    # Locale strings might include HTML tags on all keys. Variables are escaped
    # by Rails anyway.
    #
    I18n.t(id, **options.merge(raise: true, default: nil)).html_safe
  rescue StandardError
    Rails.logger.warn $ERROR_INFO
    options[:default].to_s
  end

  def avatar(*attrs)
    options = attrs.extract_options!
    user    = attrs.first || current_user
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
    "#{@title} - #{OpenMensa::TITLE}" unless @title
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
      id: (options[:id] || "map"),
      data: {
        map: (options[:id] || "map"),
        markers: markers.to_json,
        hash: options[:hash]
      }
    )
  end

  def canteen_state_icon(fetch_state)
    {
      out_of_order: :"icon-ban-circle",
      no_fetch_ever: :"icon-balt",
      fetch_up_to_date: :"icon-ok",
      fetch_needed: :"icon-warning-sign"
    }[fetch_state]
  end
end
