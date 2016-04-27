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
      # @option params [String] :uri_fragment (see uri_fragment)
      # @option params [String] :uri_method (see uri_method)
      def initialize(params = {})
        begin
          client = params[:client]
          client = Reliquary::Client.new unless client.kind_of? Reliquary::Client
          @client = client

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

      # @!method query_params
      # Return the data structure describing the parameters for modifying a
      #   particular API method's queries
      # @param [Symbol] method_name API method
      # @return [Hash] immutable hash of query params for the API method
      # @class
      def self.method_params(method_name)
        begin
          self::METHOD_PARAMS.fetch(method_name.to_sym).freeze

        rescue KeyError => e
          raise "'#{method_name}' does not look like an API method implemented by #{self}: #{e.message}"

        rescue NameError => e
          raise "#{self} does not appear to have implemented query params: #{e.message}"

        rescue StandardError => e
          raise e
        end
      end

      protected

      # @!method build_request_params
      # API requests optionally take parameters that modify their behavior;
      #   calling this method builds up a hash of the parameters that will be
      #   passed to the request.  Essentially, it translates Ruby parameters
      #   into the literal strings that will be appended to the HTTP request.
      # @param [Hash] params Parameters for this method
      # @option params [Hash] :request_params Accumulated API request parameters
      # @option params [Symbol] :filter_param
      # @option params [Symbol] :filter_value
      # @option params [Symbol] :api_method
      def build_request_params(params)

        begin
          # these are the parameters that will eventually be passed to the REST
          # API request; expect these to accumulate over multiple invocations
          # of this method.  You must return this hash, either modified or
          # unmodified.
          request_params = params.fetch(:request_params)

          # this is a Symbol representing the type of modification that will be
          # made to the API request; it's a lookup key
          method_param = params.fetch(:method_param)

          # this is a String representing the parameter that will be passed to
          # the API request modification (_e.g._ if the modification is "filter
          # by language type", this value specifies the language type)
          param_value = params.fetch(:param_value)

          # this is a Symbol representing the REST API method that will be queried
          api_method = params.fetch(:api_method)

          method_params = self.class.method_params(api_method.to_sym).fetch(method_param)

          if param_value.nil?
            request_params
          else
            param_key = method_params.fetch(:key)

            param_transform = method_params.fetch(:transform, lambda {|x| x.to_s})

            request_params.store(param_key.to_s, param_transform.call(param_value))

            request_params
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
