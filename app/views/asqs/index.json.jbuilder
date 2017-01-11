json.array!(@asqs) do |asq|
  json.extract! asq, :id, :name, :query, :database, :created_by, :modified_by, :created_on, :modified_on, :run_frequency
  json.url asq_url(asq, format: :json)
end
