class AddOldEmailToSpreeUsers < ActiveRecord::Migration
  def change
    change_table Spree.user_class.table_name.to_sym do |t|
      t.string :old_email
    end
  end
end
