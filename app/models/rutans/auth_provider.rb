# == Schema Information
#
# Table name: rutans_auth_providers
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(64)       not null
#  uid        :string(128)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Rutans
  class AuthProvider < ApplicationRecord
    self.table_name = 'rutans_auth_providers'

    belongs_to :user
    validates :user,
              presence: true

    def self.from_omniauth(auth)
      auth = self.find_by(name: auth['provider'], uid: auth['uid'])
      return auth if auth

      ActiveRecord::Base.transaction do
        user = ::User.create!(
          email: auth['info']['email']
        )

        self.create!(
          name: auth['provider'],
          uid: auth['uid'],
          user: user
        )
      end
    end
  end
end
