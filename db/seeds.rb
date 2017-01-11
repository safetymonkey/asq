# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

db = Database.create(
  name: 'local pg',
  db_type: 'postgres',
  hostname: 'localhost',
  username: 'asq',
  password: 'asq_password',
  db_name: 'asq_development',
  port: 5432)

Asq.create(
  name: 'testReport',
  query: 'Select 1 as data',
  query_type: 'report',
  alert_value: 0,
  status: 'clear_still',
  database: db
)

Asq.create(
  name: 'testMonitor',
  query: 'Select 1 as data',
  query_type: 'monitor',
  alert_value: 0,
  status: 'clear_still',
  database: db,
  alert_result_type: 'rows_count',
  alert_operator: '!=',
  refresh_in_progress: false,
  deliver_on_every_refresh: false,
  deliver_on_all_clear: false,
  disable_auto_refresh: false
)
