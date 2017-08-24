class AddAuthor20170822160720829 < Jennifer::Migration::Base
  def up
    create_table :authors do |t|
      t.string :name
      t.string :last_name
    end
    change_table :films do |t|
      t.add_column :author_id, :integer
    end
  end

  def down
    drop_table :authors
    change_table :films do |t|
      t.drop_column :author_id
    end
  end
end
