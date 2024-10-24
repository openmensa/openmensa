# frozen_string_literal: true

module OmniAuth
  module Strategies
    # Implements an OmniAuth strategy to get a Microsoft Graph
    # compatible token from Azure AD
    class Microsoft < OmniAuth::Strategies::OAuth2
      option :name, :microsoft

      DEFAULT_SCOPE = "openid email profile"

      # Configure the Microsoft identity platform endpoints
      option :client_options,
        site: "https://login.microsoftonline.com",
        authorize_url: "/common/oauth2/v2.0/authorize",
        token_url: "/common/oauth2/v2.0/token"

      option :pcke, true
      option :authorize_options, %i[scope prompt]

      uid { raw_info["oid"] }

      info do
        {
          name: raw_info["name"],
          email: raw_info["email"] || raw_info["upn"],
          nickname: raw_info["unique_name"],
          first_name: raw_info["given_name"],
          last_name: raw_info["family_name"]
        }
      end

      extra do
        {raw_info:}
      end

      # https://docs.microsoft.com/en-us/azure/active-directory/develop/id-tokens
      #
      # Some account types from Microsoft seem to only have a decodable
      # ID token, with JWT unable to decode the access token.
      # Information is limited in those cases. Other account types
      # provide an expanded set of data inside the auth token, which
      # does decode as a JWT.
      #
      # Merge the two, allowing the expanded auth token data to
      # overwrite the ID token data if keys collide, and use this as raw
      # info.
      #
      def raw_info
        if @raw_info.nil?
          id_token_data = begin
            ::JWT.decode(access_token.params["id_token"], nil, false).first
          rescue StandardError
            {}
          end

          auth_token_data = begin
            ::JWT.decode(access_token.token, nil, false).first
          rescue StandardError
            {}
          end

          id_token_data.merge!(auth_token_data)
          @raw_info = id_token_data
        end

        @raw_info
      end

      def authorize_params
        super.tap do |params|
          params[:scope] = request.params["scope"] if request.params["scope"]
          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      # Override callback URL
      #
      # OmniAuth by default passes the entire URL of the callback,
      # including query parameters. Azure fails validation because that
      # doesn't match the registered callback.
      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end
    end
  end
end
