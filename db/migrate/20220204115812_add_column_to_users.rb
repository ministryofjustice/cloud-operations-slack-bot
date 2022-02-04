class AddColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :channel_handle, :string
  end
end
