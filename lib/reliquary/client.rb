# @markup markdown
# @title Reliquary::Client
# @author Steve Huff
#

require 'multi_json'
require 'rest-client'
require 'uri'

module Reliquary
  class Client

    HTTP_METHODS = ['get','put','post','patch','delete','head']

    API_BASE = 'https://api.newrelic.com/v2/'

    # @!attribute [r] api_key
    #   @return [String] a [New Relic REST API](https://rpm.newrelic.com/api/explore) key
    attr_reader :api_key

    # @!attribute [r] api_base
    #   @return [URI] the base URI on which additional REST calls will be built
    attr_reader :api_base

    # @!method initialize(api_key = get_api_key_from_env, api_base = API_V2_BASE)
    #   Constructor method
    #   @param api_key [String] (see api_key)
    #   @return [Reliquary::Client] the initialized client
    #
    def initialize(api_key = nil, api_base = API_BASE)
      begin
        # get API key from env if not provided
        api_key = get_api_key_from_env if api_key.nil?

        @api_key = validate_api_key(api_key)
        @api_base = build_api_base(api_base)

      rescue NoMethodError => e
        false

      rescue StandardError => e
        raise e
      end
    end

    # @!method parse(json)
    #   Parse returned JSON into a Ruby object
    #
    #   @param [String] json JSON-formatted string
    #   @return [Object] Ruby object representing JSON-formatted string
    def parse(json)
      begin
        # strip off some layers of nonsense added by Oj
        MultiJson.load(json, :symbolize_keys => true).values[0]

      rescue StandardError => e
        raise e
      end
    end

    # @!method method_missing(method_name, *args, &block)
    #   Delegate HTTP method calls to RestClient::Resource
    #
    #   @param method_name [Symbol] name of method (must be a member of
    #     {Reliquary::Client::HTTP_METHODS})
    #   @param args [Array] additional method params
    #   @param block [Proc] block to which method will yield
    def method_missing(method_name, *args, &block)
      begin
        self.api_base.send(method_name.to_sym, *args, &block)

      rescue StandardError => e
        raise e
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      HTTP_METHODS.include?(method_name.to_s) || super
    end

    private

    def build_api_base(uri)
      begin
        validated_uri = URI(uri)

        RestClient::Resource.new(validated_uri.to_s, :headers => auth_header)

      rescue URI::InvalidURIError => e
        raise "'#{uri}' does not look like a valid URI"

      rescue StandardError => e
        raise e
      end
    end


    def validate_api_key(api_key)
      begin
        if /^[\h]{47}$/ =~ api_key
          api_key
        else
          raise "'#{api_key}' does not look like a valid New Relic REST API key"
        end

      rescue StandardError => e
        raise e
      end
    end

    def auth_header(api_key = self.api_key)
      begin
        {:x_api_key => api_key}

      rescue StandardError => e
        raise e
      end
    end

    def get_api_key_from_env(env = ENV)
      begin
        env.fetch('NEW_RELIC_API_KEY', env.fetch('NEWRELIC_API_KEY', nil))

      rescue NoMethodError => e
        raise "that doesn't look like a valid environment: #{e.message}"

      rescue StandardError => e
        raise e
      end
    end

  end
end
