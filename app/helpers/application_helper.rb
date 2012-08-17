module ApplicationHelper

  def t(*attrs)
    options = attrs.extract_options!
    id      = attrs.join '.'

    options[:default] ||= "[[#{id}]]"
    I18n.t(id, options.merge({ raise: true, default: nil})).html_safe
  rescue
    Rails.logger.warn $!
    options[:default].to_s
  end

  def avatar(*attrs)
    options = attrs.extract_options!
    user    = attrs.first || User.current
    if user
      image_tag user.gravatar_url(options).to_s,
        alt:   user.login,
        class: 'avatar',
        style: options[:size] ? "width: #{options[:size]}px; height: #{options[:size]}px;" : ''
    else
      content_tag :span, class: 'avatar', style: "width: #{options[:size]}px; height: #{options[:size]}px;" do
        ""
      end
    end
  end

  def connect_service_links
    links = {}
    User.current.identities.each do |id|
      if Rails.configuration.omniauth_services.include? id.provider.to_s
        links[id.provider.to_sym] = link_to "", "#",
          class: "icon-#{id.provider}-sign"
      end
    end

    Rails.configuration.omniauth_services.each do |id|
      links[id] = link_to "", auth_path(id),
        class: "icon-#{id}-sign inactive", title: t(:tip, :connect_account, id) unless links[id.to_sym]
    end

    links.map{|k,v| v}.join('').html_safe
  end

  def login_service_links
    Rails.configuration.omniauth_services.map do |id|
      link_to "", auth_path(id), class: "icon-#{id}-sign inactive", title: t(:tip, :login_account, id)
    end.join('').html_safe
  end

  def icon(icon)
    "<i class=\"icon-#{icon}\"></i>".html_safe
  end

  def title
    "#{@title} - #{OpenMensa::TITLE}" unless @title
    OpenMensa::TITLE
  end

  def set_title(title)
    @title = title.to_s
  end

  def body_classes
    ["#{controller.controller_name}_controller", "#{params[:action] || 'unknown'}_action", @layout].join(' ').strip
  end

  def render_navigation_item(text, url, options = {})
    n = render_navigation renderer: :links, items: [{ key: :anon, name: text, url: url, options: options }]
    n.gsub(/<\/?div>/, '').html_safe
  end

  def map(canteens, options = {})
    canteens = [ canteens ] unless canteens.is_a?(Array)
    markers = canteens.map do |canteen|
      {
        lat: canteen.latitude,
        lng: canteen.longitude,
        title: canteen.name,
        url: canteen_path(canteen)
      }
    end
    content_tag :div, nil, class: "map", id: (options[:id] || "map"), data: { map: (options[:id] || "map"), markers: markers.to_json}
  end
end
