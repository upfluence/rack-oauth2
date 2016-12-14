module Rack
  module OAuth2
    module Server
      module Abstract
        class Request < Rack::Request
          JSON_CONTENT_TYPE = 'application/json'

          include AttrRequired, AttrOptional
          attr_optional :client_id
          attr_optional :scope

          def params
            @params ||= if content_type == JSON_CONTENT_TYPE
                          payload = body.read
                          body.rewind
                          JSON.parse(payload)
                        else
                          super
                        end
          end

          def initialize(env)
            super
            @client_id ||= params['client_id']
            @scope = Array(params['scope'].to_s.split(' '))
          end

          def attr_missing!
            if params['client_id'].present? && @client_id != params['client_id']
              invalid_request! 'Multiple client credentials are provided.'
            end
            super
          rescue AttrRequired::AttrMissing => e
            invalid_request! e.message, state: @state, redirect_uri: @redirect_uri
          end
        end
      end
    end
  end
end
