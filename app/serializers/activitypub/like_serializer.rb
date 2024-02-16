# frozen_string_literal: true

class ActivityPub::LikeSerializer < ActivityPub::Serializer
  attributes :id, :type, :actor
  attribute :virtual_object, key: :object

  attribute :emoji_content, key: :content
  attribute :emoji_content, key: :_misskey_reaction
  attribute :tag

  def id
    [ActivityPub::TagManager.instance.uri_for(object.account), '#likes/', object.id].join
  end

  def type
    'Like'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object.status)
  end

  def emoji_content
    return nil unless object.fd_emoji_reaction

    if object.fd_emoji_reaction.custom_emoji
      ":#{object.fd_emoji_reaction.name}:"
    else
      object.fd_emoji_reaction.name
    end
  end

  def tag
    emoji = object&.fd_emoji_reaction&.custom_emoji
    return [] unless emoji

    [
      {
        icon: {
          type: 'Image',
          mediaType: emoji.image_content_type,
          url: emoji.uri,
        },
      },
    ]
  end
end
