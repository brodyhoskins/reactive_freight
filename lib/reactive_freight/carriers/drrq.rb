# frozen_string_literal: true

module ReactiveShipping
  class DRRQ < ReactiveShipping::Carrier
    REACTIVE_FREIGHT_CARRIER = true

    cattr_reader :name, :scac
    @@name = 'TForce Worldwide'
    @@scac = 'DRRQ'

    def available_services
      nil
    end

    def requirements
      %i[username password]
    end

    # Documents
    def find_pod(tracking_number, options = {})
      options = @options.merge(options)
      parse_pod_response(tracking_number, options)
    end

    # Rates

    # Tracking

    protected

    def build_url(action, *)
      url = "#{@conf.dig(:api, :domain)}#{@conf.dig(:api, :endpoints, action)}"
    end

    def commit(action, options = {})
      options = @options.merge(options)
      url = request_url(action)

      if @conf.dig(:api, :methods, action) == :post
        options[:params].blank? ? HTTParty.post(url) : HTTParty.post(url, query: options[:params])
      else
        HTTParty.get(url)
      end
    end

    def request_url(action)
      scheme = @conf.dig(:api, :use_ssl, action) ? 'https://' : 'http://'
      "#{scheme}#{@conf.dig(:api, :domain)}#{@conf.dig(:api, :endpoints, action)}"
    end

    # Documents

    def parse_document_response(type, tracking_number, url, options = {})
      options = @options.merge(options)

      raise ReactiveShipping::ResponseError, "API Error: #{self.class.name}: Document not found" if url.blank?

      path = if options[:path].blank?
               File.join(Dir.tmpdir, "#{self.class.name} #{tracking_number} #{type.to_s.upcase}.pdf")
             else
               options[:path]
             end
      file = File.new(path, 'w')

      File.open(file.path, 'wb') do |file|
        URI.parse(url).open do |input|
          file.write(input.read)
        end
      rescue OpenURI::HTTPError
        raise ReactiveShipping::ResponseError, "API Error: #{self.class.name}: Document not found"
      end

      unless url.end_with?('.pdf')
        file = Magick::ImageList.new(file.path)
        file.write(path)
      end

      File.exist?(path) ? path : false
    end

    def parse_pod_response(tracking_number, options = {})
      options = @options.merge(options)
      browser = Watir::Browser.new(:chrome, headless: !@debug)
      browser.goto(build_url(:pod))

      browser.text_field(name: 'UserId').set(options[:username])
      browser.text_field(name: 'Password').set(options[:password])
      browser.button(name: 'submitbutton').click

      browser
        .element(xpath: '//*[@id="__AppFrameBaseTable"]/tbody/tr[2]/td/div[4]')
        .click

      browser.iframes(src: '../mainframe/MainFrame.jsp?bRedirect=true')
      browser.iframe(name: 'AppBody').frame(id: 'Header')
             .text_field(name: 'filter')
             .set(tracking_number)
      browser.iframe(name: 'AppBody').frame(id: 'Header').button(value: 'Find')
             .click
      browser.iframe(name: 'AppBody').frame(id: 'Detail')
             .iframe(id: 'transportsWin')
             .element(xpath: '/html/body/div/table/tbody/tr[2]/td[1]/span/a[2]')
             .click
      browser.iframe(name: 'AppBody').frame(id: 'Detail')
             .element(xpath: '/html/body/div[1]/div/div/div[1]/div[1]/div[2]/div/a[5]')
             .click

      html = browser.iframe(name: 'AppBody').frame(id: 'Detail').iframes[1]
                    .element(xpath: '/html/body/table[3]')
                    .html
      html = Nokogiri::HTML(html)

      browser.close

      url = nil
      html.css('tr').each do |tr|
        tds = tr.css('td')
        next if tds.size <= 1 || tds.blank?

        text = tds[1].text
        next unless text&.include?('http')

        url = text if url.blank? || !url.include?('hubtran') # Prefer HubTran
      end

      parse_document_response(:pod, tracking_number, url, options)
    end

    # Rates

    # Tracking
  end
end
