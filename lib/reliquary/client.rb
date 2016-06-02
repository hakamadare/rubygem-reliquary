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

    VALID_ENV_KEYS = [
      'NEW_RELIC_API_KEY',
      'NEWRELIC_API_KEY',
    ]

    VALID_ENV_ACCOUNT_IDS = [
      'NEW_RELIC_ACCOUNT_ID',
    ]

    # @!attribute [r] api_key
    #   @return [String] a [New Relic REST API](https://rpm.newrelic.com/api/explore) key
    attr_reader :api_key

    # @!attribute [r] account_id
    #   @return [String] a New Relic account ID
    attr_reader :account_id

    # @!attribute [r] api_base
    #   @return [URI] the base URI on which additional REST calls will be built
    attr_reader :api_base

    # @!method initialize(api_key = nil, account_id = nil, api_base = API_BASE, valid_env_keys = VALID_ENV_KEYS)
    #   Constructor method
    #   @param api_key [String] (see api_key)
    #   @return [Reliquary::Client] the initialized client
    #
    def initialize(api_key = nil, api_base = API_BASE, valid_env_keys = VALID_ENV_KEYS, valid_env_account_ids = VALID_ENV_ACCOUNT_IDS)
      begin
        puts "valid_env_keys: #{valid_env_keys.inspect}"

        # get API key from env if not provided
        api_key = get_value_from_env(valid_env_keys) if api_key.nil?

        @api_key = validate_api_key(api_key)

        # get account ID from env
        account_id = get_value_from_env(valid_account_ids)

        @account_id = validate_account_id(account_id)

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
        elsif /^[\h]{33}$/ =~ api_key
          api_key
        else
          raise "'#{api_key}' does not look like a valid New Relic REST API key or a valid New Relic Insights API Query key"
        end

      rescue StandardError => e
        raise e
      end
    end

    def validate_account_id(account_id)
      begin
        if /^[\d]+$/ =~ account_id
          account_id
        else
          raise "'#{account_id}' does not look like a valid New Relic REST account id"
        end

      rescue StandardError => e
        raise e
      end
    end

    def auth_header(api_key = self.api_key, header_name = :x_api_key)
      begin
        {header_name => api_key}

      rescue StandardError => e
        raise e
      end
    end

    def get_value_from_env(env_vars = VALID_ENV_KEYS, env = ENV)
      begin
        # iterate over env vars, find the first one that is defined
        # reverse the array of env vars because i want the earliest env var to
        # win if multiple vars are defined in the env
        env_vars.reverse.reduce do |value, env_var|
          puts "env_var: #{env_var}"
          env_value = env.fetch(env_var, nil)
          puts "env_value: #{env_value.to_s}"
          env_value.nil? ? value : env_value
        end

      rescue NoMethodError => e
        raise "bogus input: #{e.message}"

      rescue StandardError => e
        raise e
      end
    end

  end
end
