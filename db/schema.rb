# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_05_27_170000) do
  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.integer "resource_id"
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "campuses", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "location"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_campuses_on_active"
    t.index ["code"], name: "index_campuses_on_code", unique: true
  end

  create_table "claims", force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "user_id", null: false
    t.string "status"
    t.text "proof_note"
    t.string "claim_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "approved_at"
    t.string "pickup_token"
    t.text "pickup_qr_payload"
    t.datetime "pickup_verified_at"
    t.integer "pickup_verified_by_id"
    t.text "rejection_reason"
    t.index ["item_id"], name: "index_claims_on_item_id"
    t.index ["pickup_token"], name: "index_claims_on_pickup_token", unique: true
    t.index ["pickup_verified_by_id"], name: "index_claims_on_pickup_verified_by_id"
    t.index ["user_id"], name: "index_claims_on_user_id"
  end

  create_table "item_conversations", force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "participant_one_id", null: false
    t.integer "participant_two_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "participant_one_id", "participant_two_id"], name: "index_item_conversations_on_item_and_participants", unique: true
    t.index ["item_id"], name: "index_item_conversations_on_item_id"
    t.index ["participant_one_id"], name: "index_item_conversations_on_participant_one_id"
    t.index ["participant_two_id"], name: "index_item_conversations_on_participant_two_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "item_type"
    t.string "category"
    t.string "location"
    t.date "found_on"
    t.string "status"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "campus_id", null: false
    t.index ["campus_id"], name: "index_items_on_campus_id"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "item_conversation_id", null: false
    t.integer "sender_id", null: false
    t.text "body", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_conversation_id", "created_at"], name: "index_messages_on_item_conversation_id_and_created_at"
    t.index ["item_conversation_id", "read_at"], name: "index_messages_on_item_conversation_id_and_read_at"
    t.index ["item_conversation_id"], name: "index_messages_on_item_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "recipient_id", null: false
    t.integer "actor_id"
    t.string "kind", default: "general", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.string "link_path"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["recipient_id", "created_at"], name: "index_notifications_on_recipient_id_and_created_at"
    t.index ["recipient_id", "read_at"], name: "index_notifications_on_recipient_id_and_read_at"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.string "department"
    t.boolean "verified", default: true, null: false
    t.integer "campus_id", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["campus_id"], name: "index_users_on_campus_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "claims", "items"
  add_foreign_key "claims", "users"
  add_foreign_key "claims", "users", column: "pickup_verified_by_id"
  add_foreign_key "item_conversations", "items"
  add_foreign_key "item_conversations", "users", column: "participant_one_id"
  add_foreign_key "item_conversations", "users", column: "participant_two_id"
  add_foreign_key "items", "campuses"
  add_foreign_key "items", "users"
  add_foreign_key "messages", "item_conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "users", "campuses"
end
