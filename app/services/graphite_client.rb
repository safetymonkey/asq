# client to send metrics to graphite
class GraphiteClient
  def initialize(host, port)
    @host = host
    @port = port
  end
end
