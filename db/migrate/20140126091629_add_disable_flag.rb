class AddDisableFlag < ActiveRecord::Migration
  def up
		add_column :users, :disabled, :boolean, default: false
  end

  def down
		remove_column :users, :disabled
  end
end
