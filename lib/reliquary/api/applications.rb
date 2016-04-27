# @markup markdown
# @title Reliquary::API::Applications
# @author Steve Huff
#

module Reliquary
  module API
    class Applications < Reliquary::API::Base

      # URI fragment for Applications API endpoint
      URI_FRAGMENT = 'applications.json'

      # URI method for Applications API endpoint
      URI_METHOD = :get

      # How to parameterize queries against API endpoint
      # These are for parameters to be added to the query; some endpoints
      #   require additional parameters to build the URI fragment.
      METHOD_PARAMS = {
        :list           => {
          :app_name     => {
            :key        => 'filter[name]',
          },
          :app_ids      => {
            :key        => 'filter[ids]',
            :transform  => lambda {|x| x.join(',')},
          },
          :app_host     => {
            :key        => 'filter[host]',
          },
          :app_lang     => {
            :key        => 'filter[language]',
          },
          :page         => {},
        },
        :show           => {},
        :metric_names   => {
          :name         => {},
          :page         => {},
        },
        :metric_data    => {
          :name         => {},
          :page         => {},
          :values       => {
            :key        => 'values[]',
            :transform  => lambda {|x| x.join(',')},
          },
          :from         => {
            :munge      => lambda {|x| self.parse_time(x)},
            :transform  => lambda {|x| self.format_time(x)},
          },
          :to           => {
            :munge      => lambda {|x| self.parse_time(x)},
            :transform  => lambda {|x| self.format_time(x)},
          },
          :period       => {
            :transform  => lambda {|x| x.to_i},
          },
          :summarize    => {
            :transform  => lambda {|x| x ? 'true' : 'false'},
          },
          :raw          => {
            :transform  => lambda {|x| x ? 'true' : 'false'},
          },
        },
        :update => {},
        :delete => {},
      }

      # @!method list
      # List applications, optionally filtering by name or ID
      # @param [Hash] params parameters for listing
      # @option [String] :app_name New Relic application name to select
      # @option [Array<String>] :app_ids New Relic application IDs to select
      # @option [String] :app_host New Relic application host to select
      # @option [String] :app_lang New Relic application language to select
      #
      def list(params = {})
        begin
          # this is the "default" Applications method, no overrides
          api_params = {}

          execute(api_params, {:params => process_request_params(__method__, params)})

        rescue StandardError => e
          raise e
        end
      end

      # @!method show
      # Show summary for a single application
      # @param [Hash] params parameters for listing
      # @option params [Integer] :id New Relic application ID
      def show(params = {})
        begin
          id = retrieve_id(params)

          # HTTP method is the default GET
          # override the URI fragment
          api_params = { :uri_fragment => "applications/#{id}.json" }

          execute(api_params, {:params => process_request_params(__method__, params)})

        rescue StandardError => e
          raise e
        end
      end

      # @!method metric_names
      # List metric names for a single application
      # @param [Hash] params parameters for listing
      # @option params [Integer] :id New Relic application ID
      def metric_names(params = {})
        begin
          id = retrieve_id(params)

          # HTTP method is the default GET
          # override the URI fragment
          api_params = { :uri_fragment => "applications/#{id}/metrics.json" }

          execute(api_params, {:params => process_request_params(__method__, params)})

        rescue StandardError => e
          raise e
        end
      end

      # @!method metric_data
      # List metric date for a single application
      # @param [Hash] params parameters for listing
      # @option params [Integer] :id New Relic application ID
      # @option params [Array<String>] :names Names of metrics to retrieve
      # @option params [Array<String>] :values Names of metric values to retrieve
      # @option params [Time] :from Retrieve metrics after this time
      # @option params [Time] :to Retrieve metrics before this time
      # @option params [Time] :period Period of timeslices in seconds
      # @option params [Boolean] :summarize Return summarized data or all the samples
      # @option params [Boolean] :raw Return unformatted data
      def metric_data(params = {})
        begin
          id = retrieve_id(params)

          names_param = params.fetch(:names).collect {|x| x.to_s}.join("\n")

          raise "you must supply one or more New Relic metric names" if names_param.nil?

          # HTTP method is the default GET
          # override the URI fragment
          api_params = { :uri_fragment => "applications/#{id}/metrics/data.json" }

          execute(api_params, {:params => process_request_params(__method__, params).merge({'names[]' => names_param})})

        rescue StandardError => e
          raise e
        end
      end

      # @!method update
      # Update certain parameters of an application
      # @param [Hash] params parameters for update
      def update(params = {})
        begin
          id = retrieve_id(params)

          raise "not implemented yet"

          # FIXME build the JSON payload

          # HTTP method is PUT
          # override the URI fragment
          api_params = {
            :uri_method => :put,
            :uri_fragment => "applications/#{id}.json",
          }

          execute(api_params, {:params => process_request_params(__method__, params)})

        rescue StandardError => e
          raise e
        end
      end

      # @!method delete
      # Delete an application and all data
      # @param [Hash] params parameters for delete
      def delete(params = {})
        begin
          id = retrieve_id(params)

          # HTTP method is PUT
          # override the URI fragment
          api_params = {
            :uri_method => :delete,
            :uri_fragment => "applications/#{id}.json",
          }

          execute(api_params, {:params => process_request_params(__method__, params)})

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
