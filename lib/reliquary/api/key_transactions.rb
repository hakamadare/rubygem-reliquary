# @markup markdown
# @title Reliquary::API::KeyTransactions
# @author Steve Huff
#

module Reliquary
  module API
    class KeyTransactions < Reliquary::API::Base

      # URI fragment for Applications API endpoint
      URI_FRAGMENT = 'key_transactions.json'

      # URI method for Applications API endpoint
      URI_METHOD = :get

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
