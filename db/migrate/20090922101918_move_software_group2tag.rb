class MoveSoftwareGroup2tag < ActiveRecord::Migration

  class ::Software < ActiveRecord::Base
    acts_as_taggable
    belongs_to :group
  end

  class ::Group < ActiveRecord::Base
    has_many :softwares
  end

  def self.up
    add_column :softwares, :cached_tag_list, :string
    Group.all.each do |g|
      g.softwares.each{|s| s.tag_list.add(g.name); s.save!}
    end
    drop_table 'groups'
    remove_column :softwares, :group_id
  end

  def self.down
    create_table "groups", :force => true do |t|
      t.column "name", :string, :limit => 80
    end
    add_column :softwares, :group_id, :integer
    add_index :softwares, :group_id
    remove_column :softwares, :cached_tag_list
  end


end
