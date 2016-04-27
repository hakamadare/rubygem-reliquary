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
      METHOD_PARAMS = {
        :list          => {
          :app_name    => {
            :key       => 'filter[name]',
          },
          :app_ids     => {
            :key       => 'filter[ids]',
            :transform => lambda {|x| x.join(',')},
          },
          :app_host    => {
            :key       => 'filter[host]',
          },
          :app_lang    => {
            :key       => 'filter[language]',
          },
          :page        => {
            :key       => 'page',
          },
        },
        :show          => {},
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
          id = params.fetch(:id).to_i

          raise "you must supply a New Relic application ID" if id.nil?

          # HTTP method is the default GET
          # override the URI fragment
          api_params = { :uri_fragment => "applications/#{id}.json" }

          execute(api_params, {:params => process_request_params(__method__, params)})

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
