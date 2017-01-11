# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170111205147) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: true do |t|
    t.integer  "activity_type"
    t.text     "detail"
    t.integer  "user_id"
    t.integer  "actable_id"
    t.string   "actable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "archived_files", force: true do |t|
    t.string   "name"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "archived_files", ["activity_id"], name: "index_archived_files_on_activity_id", using: :btree

  create_table "asq_statuses", force: true do |t|
    t.integer  "status_enum"
    t.integer  "sort_priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asqs", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "query"
    t.integer  "database_id"
    t.integer  "deprecated_2016_06_28_run_frequency", default: 5,                     null: false
    t.datetime "last_run",                            default: '1999-09-09 00:00:00', null: false
    t.text     "result"
    t.string   "created_by"
    t.datetime "created_on"
    t.string   "modified_by"
    t.datetime "modified_on"
    t.datetime "deprecated_2016_06_28_created_at"
    t.datetime "deprecated_2016_06_28_updated_at"
    t.string   "related_tickets"
    t.boolean  "email_alert"
    t.string   "deprecated_2016_06_28_email_to"
    t.float    "query_run_time"
    t.string   "alert_result_type"
    t.string   "alert_operator"
    t.string   "alert_value"
    t.boolean  "refresh_in_progress",                 default: false,                 null: false
    t.boolean  "deliver_on_every_refresh"
    t.boolean  "deliver_on_all_clear"
    t.boolean  "email_attachment",                    default: true,                  null: false
    t.boolean  "disable_auto_refresh",                default: false,                 null: false
    t.integer  "query_type",                          default: 1
    t.string   "filename"
    t.integer  "status",                              default: 3
    t.boolean  "disabled"
  end

  create_table "databases", force: true do |t|
    t.string   "name"
    t.string   "db_type_old"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hostname"
    t.string   "username"
    t.text     "password"
    t.string   "db_name"
    t.integer  "port"
    t.integer  "db_type"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deliveries", force: true do |t|
    t.integer  "asq_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "deliverable_id",   default: 0,      null: false
    t.string   "deliverable_type", default: "None", null: false
  end

  add_index "deliveries", ["asq_id"], name: "index_deliveries_on_asq_id", using: :btree
  add_index "deliveries", ["deliverable_id"], name: "index_deliveries_on_deliverable_id", using: :btree
  add_index "deliveries", ["deliverable_type"], name: "index_deliveries_on_deliverable_type", using: :btree

  create_table "direct_ftp_deliveries", force: true do |t|
    t.string   "host"
    t.integer  "port"
    t.string   "directory"
    t.string   "username"
    t.text     "password"
    t.integer  "asq_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "direct_ftp_deliveries", ["asq_id"], name: "index_direct_ftp_deliveries_on_asq_id", using: :btree

  create_table "direct_sftp_deliveries", force: true do |t|
    t.string   "host"
    t.integer  "port"
    t.string   "directory"
    t.string   "username"
    t.text     "password"
    t.integer  "asq_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "direct_sftp_deliveries", ["asq_id"], name: "index_direct_sftp_deliveries_on_asq_id", using: :btree

  create_table "email_deliveries", force: true do |t|
    t.string  "to"
    t.string  "from"
    t.string  "subject"
    t.text    "body"
    t.integer "asq_id"
    t.boolean "attach_results"
  end

  add_index "email_deliveries", ["asq_id"], name: "index_email_deliveries_on_asq_id", using: :btree

  create_table "file_options", force: true do |t|
    t.integer  "asq_id"
    t.string   "name"
    t.string   "line_end"
    t.string   "delimiter"
    t.string   "quoted_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sub_character",     default: ""
  end

  add_index "file_options", ["asq_id"], name: "index_file_options_on_asq_id", using: :btree

  create_table "json_deliveries", force: true do |t|
    t.string   "url"
    t.integer  "asq_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "json_deliveries", ["asq_id"], name: "index_json_deliveries_on_asq_id", using: :btree

  create_table "schedules", force: true do |t|
    t.string   "type"
    t.time     "time_old"
    t.integer  "param"
    t.integer  "asq_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time"
    t.string   "time_zone"
  end

  add_index "schedules", ["asq_id"], name: "index_schedules_on_asq_id", using: :btree

  create_table "settings", force: true do |t|
    t.string   "var",        null: false
    t.text     "value",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "third_party_hooks", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "command"
    t.string   "json_template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "login",                    default: "",    null: false
    t.string   "email",                    default: "",    null: false
    t.string   "name",                     default: "",    null: false
    t.string   "firstname",                default: "",    null: false
    t.string   "lastname",                 default: "",    null: false
    t.string   "remember_token",           default: ""
    t.boolean  "is_admin",                 default: false, null: false
    t.boolean  "is_editor",                default: false, null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_release_note_viewed", default: 0
    t.string   "encrypted_password",       default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "zenoss_deliveries", force: true do |t|
    t.integer  "asq_id"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zenoss_deliveries", ["asq_id"], name: "index_zenoss_deliveries_on_asq_id", using: :btree

end
