# frozen_string_literal: true

class REST::FdEmojiReactionSerializer < ActiveModel::Serializer
  attributes :id, :name

  belongs_to :custom_emoji, serializer: REST::CustomEmojiSerializer

  def id
    object.id.to_s
  end
end
