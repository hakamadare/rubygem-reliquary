# @markup markdown
# @title Reliquary::API::Base
# @author Steve Huff
#

module Reliquary
  module API
    # @abstract
    class Base

      # @!attribute [r] client
      #   @return [Reliquary::Client] the API client to be used for requests
      attr_reader :client

      # @!attribute [r] filter_options
      #   @return [Hash] options for filtering API requests
      attr_reader :filter_options

      # @!attribute [r] uri_fragment
      #   @return [String] URI fragment defining the API endpoint
      attr_reader :uri_fragment

      # @!attribute [r] uri_method
      #   @return [Symbol] default URI method to be used for requests to the API endpoint
      attr_reader :uri_method

      # @!method initialize(params = {})
      # Constructor method for base API component
      # @param [Hash] params parameters for component
      # @option params [Reliquary::Client] :client (see client)
      # @option params [Hash] :filter_options (see filter_options)
      # @option params [String] :uri_fragment (see uri_fragment)
      # @option params [String] :uri_method (see uri_method)
      def initialize(params = {})
        begin
          client = params[:client]
          client = Reliquary::Client.new unless client.kind_of? Reliquary::Client
          @client = client

          filter_options = params[:filter_options]
          filter_options = self.class::FILTER_OPTIONS unless filter_options.kind_of? Hash
          @filter_options = filter_options

          uri_fragment = params[:uri_fragment]
          uri_fragment = self.class::URI_FRAGMENT unless uri_fragment.kind_of? String
          @uri_fragment = uri_fragment

          uri_method = params[:uri_method]
          uri_method = self.class::URI_METHOD unless uri_method.kind_of? String
          @uri_method = uri_method

        rescue StandardError => e
          raise e
        end
      end

      # @!method execute(*args, &block)
      # Execute a HTTP request using the API client
      # @param [Hash] params parameters for request
      # @option params [Symbol] :uri_method (see uri_method)
      # @option params [String] :uri_fragment (see uri_fragment)
      # @param [Array] args parameters for request
      # @param [Proc] block block to which request will yield
      def execute(params, *args, &block)
        begin
          raise "params must be a Hash" unless params.kind_of? Hash

          uri_fragment = params.fetch(:uri_fragment, self.uri_fragment)
          uri_method = params.fetch(:uri_method, self.uri_method)

          resp = self.client[uri_fragment].send(uri_method, *args, &block)

          self.client.parse(resp)

        rescue MultiJson::ParseError => e
          raise "unable to parse JSON: #{e.message}"

        rescue StandardError => e
          raise e
        end
      end

      protected

      def filter_option(params)

        begin
          query_params = params.fetch(:query_params)
          filter_param = params.fetch(:filter_param)
          filter_value = params.fetch(:filter_value)
          api_method = params.fetch(:api_method)
          filter_options = params.fetch(:filter_options, self.filter_options)

          if filter_value.nil?
            query_params
          else
            filter_opts = filter_options.fetch(api_method.to_sym).fetch(filter_param.to_sym)

            filter_key = filter_opts.fetch(:key)

            filter_transform = filter_opts.fetch(:transform, lambda {|x| x.to_s})

            query_params.store(filter_key.to_s, filter_transform.call(filter_value))

            query_params
          end

        rescue KeyError => e
          raise "unable to find filter options for API method '#{api_method}': #{e.message}"

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
