# frozen_string_literal: true

class ActivityPub::Activity::Like < ActivityPub::Activity
  def perform
    original_status = status_from_uri(object_uri)

    return if original_status.nil? || !original_status.account.local? || delete_arrived_first?(@json['id']) || @account.favourited?(original_status)

    favourite = original_status.favourites.create!(account: @account)
    process_reaction(favourite)

    LocalNotificationWorker.perform_async(original_status.account_id, favourite.id, 'Favourite', 'favourite')
    Trends.statuses.register(original_status)
  end

  private

  # for fd.toripota.com
  def process_reaction(favourite)
    reaction_content = @json['content']
    return unless reaction_content

    tag = (@json['tag'] || [])[0]
    emoji = tag ? process_emoji(tag) : nil

    FdEmojiReaction.create(
      favourite_id: favourite.id,
      name: emoji&.shortcode || reaction_content,
      custom_emoji_id: emoji&.id
    )
  end

  # from ActivityPub::Activity::Create
  def process_emoji(tag)
    return nil if skip_download?

    custom_emoji_parser = ActivityPub::Parser::CustomEmojiParser.new(tag)

    return nil if custom_emoji_parser.shortcode.blank? || custom_emoji_parser.image_remote_url.blank?

    emoji = CustomEmoji.find_by(shortcode: custom_emoji_parser.shortcode, domain: @account.domain)

    return emoji unless emoji.nil? ||
                        custom_emoji_parser.image_remote_url != emoji.image_remote_url ||
                        (custom_emoji_parser.updated_at && custom_emoji_parser.updated_at >= emoji.updated_at)

    begin
      emoji ||= CustomEmoji.new(domain: @account.domain, shortcode: custom_emoji_parser.shortcode, uri: custom_emoji_parser.uri)
      emoji.image_remote_url = custom_emoji_parser.image_remote_url
      emoji.save

      emoji
    rescue Seahorse::Client::NetworkingError => e
      Rails.logger.warn "Error storing emoji: #{e}"

      nil
    end
  end

  # from ActivityPub::Activity::Create
  def skip_download?
    return @skip_download if defined?(@skip_download)

    @skip_download ||= DomainBlock.reject_media?(@account.domain)
  end
end
