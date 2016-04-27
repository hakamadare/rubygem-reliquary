# @markup markdown
# @title Reliquary::API::Base
# @author Steve Huff
#
require 'chronic'

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

          # FIXME check HTTP response code here

          self.client.parse(resp)

        rescue MultiJson::ParseError => e
          raise "unable to parse JSON: #{e.message}"

        rescue StandardError => e
          raise e
        end
      end

      # @!method method_params
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

      # @!method retrieve_id
      # Retrieve New Relic ID from a params hash
      # @param [Hash] params Hash of parameters
      # @param [Symbol] id_key Hash key associated with ID value (default `:id`)
      # @return [Integer] New Relic ID
      def retrieve_id(params, id_key = :id)
        begin
          id_val = params.fetch(id_key.to_sym)

          if id_val.nil?
            raise "you must supply a New Relic application ID"
          else
            id_val.to_i
          end

        rescue NoMethodError => e
          raise "unable to convert '#{id_val.inspect}' to integer: #{e.message}"

        rescue KeyError => e
          raise "the params hash has no key called '#{id_key}': #{e.message}"

        rescue StandardError => e
          raise e
        end
      end

      # @!method process_request_params
      # Iterate over an API method's parameters, building up a hash of URI
      #   query parameters that will be added to the REST API query.
      # @param [Symbol] api_method The REST API method that is being called
      # @param [Hash] query_params The modifications to be made to this
      #   particular REST API request
      # @return [Hash] parameters to be passed to execute() method
      def process_request_params(api_method, query_params)
        begin
          this_methods_params = self.class.method_params(api_method.to_sym)

          request_params = {}

          this_methods_params.keys.each do |k|
            request_params = build_request_params(request_params: request_params, method_param: k.to_sym, param_value: query_params[k.to_sym], method_params: this_methods_params)
          end

          request_params

        rescue StandardError => e
          raise e
        end
      end

      # @!method build_request_params
      # API requests optionally take parameters that modify their behavior;
      #   calling this method builds up a hash of the parameters that will be
      #   passed to the request.  Essentially, it translates Ruby parameters
      #   into the literal strings that will be appended to the HTTP request.
      # @param [Hash] params Parameters for this method
      # @option params [Hash] :request_params Accumulated API request parameters
      # @option params [Symbol] :method_param
      # @option params [Symbol] :param_value
      # @option params [Symbol] :method_params
      # @return [Hash] (see :request_params)
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

          # this is a Hash specifying the API parameter being built
          method_params = params.fetch(:method_params)

          this_requests_params = method_params.fetch(method_param)

          if param_value.nil?
            request_params
          else
            # default param key is the method param, stringified
            param_key = this_requests_params.fetch(:key, method_param.to_s)

            param_transform = this_requests_params.fetch(:transform, lambda {|x| x.to_s})
            param_munge = this_requests_params.fetch(:munge, lambda {|x| x})

            request_params.store(param_key.to_s, param_transform.call(param_munge.call(param_value)))

            request_params
          end

        rescue KeyError => e
          raise "unable to find filter options for API method '#{api_method}': #{e.message}"

        rescue StandardError => e
          raise e
        end
      end

      # @! method parse_time
      # Parses and validates a time parameter (accepts ISO8601 format and some
      # "natural language" formats), converting to UTC
      # @param [String] time String to be parsed
      # @return [Time] parsed Time object
      def self.parse_time(time)
        begin
          Chronic.parse(time).utc

        rescue NoMethodError => e
          raise "unable to parse '#{time}' as a time: #{e.message}"

        rescue StandardError => e
          raise e
        end
      end

      # @! method format_time
      # Converts a Time object to an ISO8601-formatted String, forcing UTC
      # @param [Time] time Time object to be formatted
      # @return [String] formatted String
      def self.format_time(time)
        begin
          time.utc.strftime('%FT%T') + '+00:00'

        rescue NoMethodError => e
          raise "unable to parse '#{time}' as a time: #{e.message}"

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
