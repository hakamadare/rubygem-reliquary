# @markup markdown
# @title Reliquary::API::Insights
# @author Steve Huff
#

module Reliquary
  module API
    class Insights < Reliquary::API::Base

      # URI base for Insights API
      API_BASE = 'https://insights-api.newrelic.com/v1'

      # URI method for Insights API endpoint
      URI_METHOD = :get

      # Environment variables which may store our API query key
      VALID_ENV_KEYS = [
        'NEW_RELIC_QUERY_KEY',
      ]

      # How to parameterize queries against API endpoint
      # These are for parameters to be added to the query; some endpoints
      #   require additional parameters to build the URI fragment.
      METHOD_PARAMS = {
        :list           => {
          :name         => {
            :key        => 'filter[name]',
          },
          :ids          => {
            :key        => 'filter[ids]',
            :transform  => lambda {|x| x.join(',')},
          },
          :page         => {},
        },
        :show           => {},
      }

      # @!method initialize(params = {})
      # Constructor method for Insights API component
      # @param [Hash] params parameters for component
      # @option params [String] :uri_method (see uri_method)
      def initialize(params = {})
        begin
          client = Reliquary::Client.new(nil, API_BASE, VALID_ENV_KEYS)
          params[:client] = client

          account_id = client.account_id

          params[:uri_fragment] = "accounts/#{account_id}/query?"

          super(params)

        rescue KeyError => e
          raise RuntimeError.new("missing parameter: #{e.message}")

        rescue StandardError => e
          raise e
        end
      end


      # @!method list
      # List key transactions, optionally filtering by name or ID
      # @param [Hash] params parameters for listing
      # @option [String] :name New Relic key transaction name to select
      # @option [Array<String>] :ids New Relic key transaction policy IDs to select
      #
      def list(params = {})
        begin
          # this is the "default" Key Transactions method, no overrides
          api_params = {}

          execute(api_params, {:params => process_request_params(__method__, params)})

        rescue StandardError => e
          raise e
        end
      end

      # @!method show
      # Show summary for a single key transaction
      # @param [Hash] params parameters for listing
      # @option params [Integer] :id New Relic key transaction ID
      def show(params = {})
        begin
          id = retrieve_id(params)

          # HTTP method is the default GET
          # override the URI fragment
          api_params = { :uri_fragment => "key_transactions/#{id}.json" }

          execute(api_params, {:params => process_request_params(__method__, params)})

        rescue StandardError => e
          raise e
        end
      end


    end
  end
end
