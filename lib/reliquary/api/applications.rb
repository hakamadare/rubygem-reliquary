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

      # Options for filtering queries against API endpoint
      FILTER_OPTIONS = {
        :list       => {
          :app_name => {
            :key => 'filter[name]',
          },
          :app_ids  => {
            :key => 'filter[ids]',
            :transform => lambda {|x| x.join(',')},
          },
          :app_host => {
            :key => 'filter[host]',
          },
          :app_lang => {
            :key => 'filter[language]',
          }
        },
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
          api_params = {}

          api_method = __method__

          query_params = {}
          query_params = filter_option(query_params: query_params, filter_param: :app_name, filter_value: params[:app_name], api_method: api_method)
          query_params = filter_option(query_params: query_params, filter_param: :app_ids, filter_value: params[:app_ids], api_method: api_method)
          query_params = filter_option(query_params: query_params, filter_param: :app_host, filter_value: params[:app_host], api_method: api_method)
          query_params = filter_option(query_params: query_params, filter_param: :app_lang, filter_value: params[:app_lang], api_method: api_method)

          execute(api_params, {:params => query_params})

        rescue StandardError => e
          raise e
        end
      end

      private

      def filter_param(query_params,k,v)
        begin
          query_params.store(k.to_s,v.to_s) unless v.nil?

        rescue StandardError => e
          raise e
        end
      end

    end
  end
end
