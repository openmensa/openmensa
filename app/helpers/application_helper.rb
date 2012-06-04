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

  def avatar_img(*attrs)
    options = {size: 100}.merge(attrs.extract_options!)
    user    = attrs.first || User.current
    if user
      image_tag user.gravatar_url(options).to_s,
        alt:   user.login,
        class: 'avatar',
        style: "width: #{options[:size]}px; height: #{options[:size]}px;"
    else
      content_tag :span, class: 'avatar', style: "width: #{options[:size]}px; height: #{options[:size]}px;" do
        ""
      end
    end
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
end
