# frozen_string_literal: true

module ReactiveShipping
  class Liftoff < ReactiveShipping::Carrier
    ACTIVE_FREIGHT_CARRIER = true

    cattr_reader :name
    @@name = 'JFJ Transportation'

    JSON_HEADERS = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'charset': 'utf-8'
    }.freeze

    # Uses ActiveShipping styled accessorials
    # ACCESSORIALS = {}.freeze

    # Uses ActiveShipping styled accessorials
    # REJECT_ACCESSORIALS = %i[].freeze

    # Uses ActiveShipping styled events
    # EVENTS = {}.freeze

    API_PREFIX = '/api/v1'

    API_ENDPOINTS = {
      authenticate: '/authenticate',
      show: '/shipments'
    }.freeze

    API_SCOPE = {
      broker: '/broker',
      customer: '/customer'
    }.freeze

    API_METHODS = {
      authenticate: :post,
      show: :get
    }.freeze

    def requirements
      %i[domain email password scope]
    end

    # Documents
    # def find_bol(tracking_number, options = {})
    # end

    # def find_pod(tracking_number, options = {})
    #  options = @options.merge(options)
    #  parse_document_response(:pod, tracking_number, options)
    # end

    # Rates
    # def find_rates(origin, destination, packages, options = {})
    # end

    def show(id)
      request = build_request(:show, params: "/#{id}")
      commit(request)
    end

    # Tracking
    # def find_tracking_info(tracking_number)
    # end

    # protected

    def build_url(action, options = {})
      url = "#{base_url}#{API_ENDPOINTS[action]}"
      url = url.sub(API_SCOPE[@options[:scope]], '') if action == :authenticate
      url << options[:params] unless options[:params].blank?
      url
    end

    def build_request(action, options = {})
      headers = JSON_HEADERS
      headers = headers.merge(options[:headers]) unless options[:headers].blank?
      body = options[:body].to_json unless options[:body].blank?

      unless action == :authenticate
        set_auth_token
        headers = headers.merge(token)
      end

      {
        url: build_url(action, options),
        headers: headers,
        method: API_METHODS[action],
        body: body
      }
    end

    def commit(request)
      url = request[:url]
      headers = request[:headers]
      method = request[:method]
      body = request[:body]

      response = case method
                 when :post
                   HTTParty.post(url, headers: headers, body: body)
                 else
                   HTTParty.get(url, headers: headers)
                 end

      JSON.parse(response.body)
    end

    def base_url
      "https://#{@options[:domain]}#{API_PREFIX}#{API_SCOPE[@options[:scope]]}"
    end

    def set_auth_token
      return @auth_token unless @auth_token.blank?

      request = build_request(
        :authenticate,
        body: {
          email: @options[:email],
          password: @options[:password]
        }
      )

      response = commit(request)
      @auth_token = response.dig('auth_token')
    end

    def token
      { 'Authorization': "Bearer #{@auth_token}" }
    end

    # Show
  end
end
