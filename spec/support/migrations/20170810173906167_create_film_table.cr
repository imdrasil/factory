class CreateFilmTable20170810173906167 < Jennifer::Migration::Base
  def up
    create_table :films do |t|
      t.string :name
      t.integer :rating, {:null => false}
      t.float :budget
    end
  end

  def down
    drop_table :films
  end
end
