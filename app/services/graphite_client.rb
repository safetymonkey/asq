require 'graphite-api'

class GraphiteClient
  def initialize(host, port, prefix)
    unless GraphiteClient.valid_metric_name? prefix
      raise ArgumentError, 'Prefix is invalid'
    end
    @graphite = GraphiteAPI.new(
      graphite: "#{host}:#{port}",
      prefix: prefix
    )
  end

  def add_metric(name, metric)
    metric = metric.to_f
    unless metric.is_a? Numeric
      raise TypeError, "Metric '#{metric}' must be numeric"
    end
    unless GraphiteClient.valid_metric_name? name
      raise ArgumentError, 'Name is invalid'
    end
    @graphite.metrics(name.to_s => metric)
  end

  def self.valid_metric_name?(raw_name)
    names = raw_name.to_s.split('.')
    names.each do |name|
      return false unless name =~ /^[a-zA-Z0-9_]*$/
    end
    true
  end
end
