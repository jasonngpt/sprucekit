class AddUserModel < ActiveRecord::Migration
  def up
	  create_table :users do |u|
		  u.string :username
		  u.string :email
		  u.string :token
		  u.timestamps
	  end
  end

  def down
	  drop_table :users
  end
end
