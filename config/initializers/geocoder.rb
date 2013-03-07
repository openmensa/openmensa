# config/initializers/geocoder.rb
Geocoder.configure(

    # geocoding service
    :lookup => :nominatim,
    :http_headers => { "User-Agent" => "RubyGeocoder openmensa.org / info@openmensa.org" },

    # geocoding service request timeout, in seconds (default 3):
    :timeout => 3,

    # set default units to kilometers:
    :units => :km,

    # caching (see below for details):
    #:cache => Redis.new,
    #:cache_prefix => "..."
)
