class ConvertToIdentities < ActiveRecord::Migration[5.0]
  def up
    ActiveRecord::Base.transaction do
      TmpProvider.find_each do |old|
        TmpIdnetity.create!(
          user_id: old.user_id,
          provider: old.name,
          uid: old.uid
        )
        user = TmpUser.find(old.user_id)
        user.update_columns(confirmed_at: Time.zone.now) if user.confirmed_at.nil?
      end
      TmpProvider.delete_all
    end
  end

  def down
    ActiveRecord::Base.transaction do
      TmpIdnetity.find_each do |old|
        TmpProvider.create!(
          user_id: old.user_id,
          name: old.provider,
          uid: old.uid
        )
      end
      TmpIdnetity.delete_all
    end
  end

  class TmpUser < ActiveRecord::Base
    self.table_name = 'users'
  end

  class TmpIdnetity < ActiveRecord::Base
    self.table_name = 'identities'
  end

  class TmpProvider < ActiveRecord::Base
    self.table_name = 'rutans_auth_providers'
  end
end
