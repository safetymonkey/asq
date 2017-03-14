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

ActiveRecord::Schema.define(version: 20170314043404) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "activity_type"
    t.text     "detail"
    t.integer  "user_id"
    t.integer  "actable_id"
    t.string   "actable_type",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "archived_files", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["activity_id"], name: "index_archived_files_on_activity_id", using: :btree
  end

  create_table "asq_statuses", force: :cascade do |t|
    t.integer  "status_enum"
    t.integer  "sort_priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asqs", force: :cascade do |t|
    t.string   "name",                                limit: 255
    t.text     "description"
    t.text     "query"
    t.integer  "database_id"
    t.integer  "deprecated_2016_06_28_run_frequency",             default: 5,                     null: false
    t.datetime "last_run",                                        default: '1999-09-09 00:00:00', null: false
    t.text     "result"
    t.string   "created_by",                          limit: 255
    t.datetime "created_on"
    t.string   "modified_by",                         limit: 255
    t.datetime "modified_on"
    t.datetime "deprecated_2016_06_28_created_at"
    t.datetime "deprecated_2016_06_28_updated_at"
    t.string   "related_tickets",                     limit: 255
    t.boolean  "email_alert"
    t.string   "deprecated_2016_06_28_email_to",      limit: 255
    t.float    "query_run_time"
    t.string   "alert_result_type",                   limit: 255
    t.string   "alert_operator",                      limit: 255
    t.string   "alert_value",                         limit: 255
    t.boolean  "refresh_in_progress",                             default: false,                 null: false
    t.boolean  "deliver_on_every_refresh"
    t.boolean  "deliver_on_all_clear"
    t.boolean  "email_attachment",                                default: true,                  null: false
    t.boolean  "disable_auto_refresh",                            default: false,                 null: false
    t.integer  "query_type",                                      default: 1
    t.string   "filename",                            limit: 255
    t.integer  "status",                                          default: 3
    t.boolean  "disabled"
  end

  create_table "autosftp_deliveries", force: :cascade do |t|
  end

  create_table "databases", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "db_type_old", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hostname",    limit: 255
    t.string   "username",    limit: 255
    t.text     "password"
    t.string   "db_name",     limit: 255
    t.integer  "port"
    t.integer  "db_type"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "deliveries", force: :cascade do |t|
    t.integer  "asq_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "deliverable_id",               default: 0,      null: false
    t.string   "deliverable_type", limit: 255, default: "None", null: false
    t.index ["asq_id"], name: "index_deliveries_on_asq_id", using: :btree
    t.index ["deliverable_id"], name: "index_deliveries_on_deliverable_id", using: :btree
    t.index ["deliverable_type"], name: "index_deliveries_on_deliverable_type", using: :btree
  end

  create_table "direct_ftp_deliveries", force: :cascade do |t|
    t.string   "host",       limit: 255
    t.integer  "port"
    t.string   "directory",  limit: 255
    t.string   "username",   limit: 255
    t.text     "password"
    t.integer  "asq_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["asq_id"], name: "index_direct_ftp_deliveries_on_asq_id", using: :btree
  end

  create_table "direct_sftp_deliveries", force: :cascade do |t|
    t.string   "host",       limit: 255
    t.integer  "port"
    t.string   "directory",  limit: 255
    t.string   "username",   limit: 255
    t.text     "password"
    t.integer  "asq_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["asq_id"], name: "index_direct_sftp_deliveries_on_asq_id", using: :btree
  end

  create_table "email_deliveries", force: :cascade do |t|
    t.string  "to",             limit: 255
    t.string  "from",           limit: 255
    t.string  "subject",        limit: 255
    t.text    "body"
    t.integer "asq_id"
    t.boolean "attach_results"
    t.index ["asq_id"], name: "index_email_deliveries_on_asq_id", using: :btree
  end

  create_table "file_options", force: :cascade do |t|
    t.integer  "asq_id"
    t.string   "name",              limit: 255
    t.string   "line_end",          limit: 255
    t.string   "delimiter",         limit: 255
    t.string   "quoted_identifier", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sub_character",     limit: 255, default: ""
    t.index ["asq_id"], name: "index_file_options_on_asq_id", using: :btree
  end

  create_table "json_deliveries", force: :cascade do |t|
    t.string   "url",        limit: 255
    t.integer  "asq_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["asq_id"], name: "index_json_deliveries_on_asq_id", using: :btree
  end

  create_table "schedules", force: :cascade do |t|
    t.string   "type",       limit: 255
    t.time     "time_old"
    t.integer  "param"
    t.integer  "asq_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time",       limit: 255
    t.string   "time_zone",  limit: 255
    t.index ["asq_id"], name: "index_schedules_on_asq_id", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",        limit: 255, null: false
    t.text     "value",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context", using: :btree
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count",             default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "third_party_hooks", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "url",           limit: 255
    t.string   "command",       limit: 255
    t.string   "json_template", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                    limit: 255, default: "",    null: false
    t.string   "email",                    limit: 255, default: "",    null: false
    t.string   "remember_token",           limit: 255, default: ""
    t.boolean  "is_admin",                             default: false, null: false
    t.boolean  "is_editor",                            default: false, null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",       limit: 255
    t.string   "last_sign_in_ip",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_release_note_viewed",             default: 0
    t.string   "encrypted_password",       limit: 255, default: "",    null: false
    t.string   "reset_password_token",     limit: 255
    t.datetime "reset_password_sent_at"
    t.string   "confirmation_token",       limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",        limit: 255
    t.boolean  "approved",                             default: false, null: false
    t.index ["approved"], name: "index_users_on_approved", using: :btree
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["login"], name: "index_users_on_login", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  create_table "zenoss_deliveries", force: :cascade do |t|
    t.integer  "asq_id"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["asq_id"], name: "index_zenoss_deliveries_on_asq_id", using: :btree
  end

end
