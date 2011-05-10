class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.column :summary, :string
      t.column :description, :string, {:null => false, :default => ''}
      t.column :title, :string, {:null => false, :default => ''}
      t.column :comments_count, :integer, {:null => true, :default => 0}
      t.column :created_on, :datetime
      t.column :project_id, :integer, {:null => false, :default => 0}
      t.column :author_id, :integer, {:null => false, :default => 0}
    end
    add_index :blogs, :project_id
    add_index :blogs, :author_id
  end

  def self.down
    drop_table :blogs
    remove_index :blogs, :project_id
    remove_index :blogs, :author_id
  end
end
