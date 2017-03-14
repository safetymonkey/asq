# Used to build and post Zenoss messages, based on a passed-in Asq object.
class ZenossService
  class << self
    # The sole way that the outside world interacts with this class.
    # Returns true if the POST action was successful. Raises an exception
    # If it doesn't. This is so it can include some error text, which it
    # can't do if it just returns "false".
    def post(asq)
      @asq = asq
      max_retries = 2 # Why 2? Why not? We can make it a Setting if we want.
      retries = max_retries
      while retries > 0
        # Broken out into its own method to keep the linter happy.
        return true if post_successful?
        retries -= 1
      end
      # If we end up here, then we've run out of retries.
      raise StandardError,\
            "Failed to post #{@asq.name} to Zenoss after "\
            "#{max_retries} tries."
    end

    protected

    # Sets the new URL to POST to before returning false. If we want to do it
    # differently, then the method needs to return something instead of a simple
    # "false" and the URL modification needs to happen upstream.
    def post_successful?
      true if RestClient::Request.execute(request).code == 200
    rescue RestClient::Exception => e
      case e.response.code
      when 300..308
        @current_zenoss_url = e.response.headers[:location]
        return false
      end
      raise StandardError, "HTTP Error #{e.response.code}"
    end

    # A request is a property bag, with some values based on some Settings.
    # Its "payload" property is also a property bag.
    def request
      {
        method: :post,
        headers: { content_type: :json, accept: :json },
        url: @current_zenoss_url ? @current_zenoss_url : Settings.zenoss_url,
        user: Settings.zenoss_username,
        password: Settings.zenoss_password,
        payload: zenoss_payload.to_json
      }
    end

    # A payload is a property bag. Its "data" property is
    # also a property bag.
    def zenoss_payload
      {
        action: 'EventsRouter',
        method: 'add_event',
        type: 'rpc',
        tid: 1,
        data: [zenoss_data]
      }
    end

    # This is a property bag, with values based on some @asq properties.
    def zenoss_data
      summary = @asq.in_alert? ? 'is in alert.' : 'is clear.'
      {
        component: @asq.name,
        device: Settings.vip_name,
        summary: "#{@asq.name} #{summary}",
        severity: @asq.in_alert? ? 'Critical' : 'Clear',
        evclasskey: 'ASQ',
        evclass: '/ASQ'
      }
    end
  end
end
