class AddMailOptions < ActiveRecord::Migration
  def up
		add_column :users, :mailoptions, :string, default: "html"
  end

  def down
		remove_column :users, :mailoptions
  end
end
