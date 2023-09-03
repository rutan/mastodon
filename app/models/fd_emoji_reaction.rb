# frozen_string_literal: true

# == Schema Information
#
# Table name: fd_emoji_reactions
#
#  id              :bigint(8)        not null, primary key
#  favourite_id    :bigint(8)
#  name            :string           not null
#  custom_emoji_id :bigint(8)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class FdEmojiReaction < ApplicationRecord
  belongs_to :favourite, inverse_of: :fd_emoji_reaction
  belongs_to :custom_emoji, optional: true

  validates :name, presence: true
end
