# frozen_string_literal: true
# for fd.toripota.com
class CreateFdEmojiReactions < ActiveRecord::Migration[6.1]
  def change
    create_table :fd_emoji_reactions do |t|
      t.references :favourite, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.string :name, null: false
      t.references :custom_emoji, foreign_key: { on_delete: :cascade }

      t.timestamps null: false
    end
  end
end
