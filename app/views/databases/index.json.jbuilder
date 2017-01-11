json.array!(@databases) do |database|
  json.extract! database, :id, :name, :hostname, :db_type, :default_db
  json.url database_url(database, format: :json)
end
