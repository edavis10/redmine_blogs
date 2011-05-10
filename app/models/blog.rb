# copied from /app/models/news.rb

class Blog < ActiveRecord::Base
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  has_many :comments, :as => :commented, :dependent => :delete_all, :order => "created_on"
	acts_as_taggable

  validates_presence_of :title, :description
  validates_length_of :title, :maximum => 255
  validates_length_of :summary, :maximum => 255

  #acts_as_searchable :columns => ['description', "#{Blog.table_name}.description"]
  #acts_as_event :url => Proc.new {|o| {:controller => 'blogs', :action => 'show', :id => o.id}}
  #acts_as_activity_provider :find_options => {:include => [:author]}

  acts_as_activity_provider :type => 'blogs',
                            :timestamp => "#{Blog.table_name}.created_on",
                            :author_key => "#{Blog.table_name}.author_id"
                            #:permission => :view_blogs

  acts_as_event :datetime => :created_on,
                :url => Proc.new {|o| {:controller => 'blogs', :action => 'show', :id => o}}, 	
								:type => 'blog-post'
 #								:title => Proc.new {|o| o.title },
  #              :description => :description,
	#               :author => :author,

  acts_as_searchable :columns => ['title', 'summary', 'description'],
                     # sort by id so that limited eager loading doesn't break with postgresql
                     :order_column => "id",
										 :project_key => ""
										 
  acts_as_attachable

	activity_provider_options["blogs"].delete(:permission)
	
  # returns latest blogs for projects visible by user
  def self.latest(user = User.current, count = 5)
    find(:all, :limit => count, :conditions => Project.allowed_to_condition(user, :view_news), :include => [ :author ], :order => "#{Blog.table_name}.created_on DESC")
  end
  def attachments_deletable?(user=User.current)
    true
  end
  def attachments_visible?(user=User.current)
    true
  end
  def project
    nil
  end
	def short_description()
		desc, more = description.split(/\{\{more\}\}/mi)
		desc
	end
	def has_more?()
		desc, more = description.split(/\{\{more\}\}/mi)
		more
	end
	def full_description()
		description.gsub(/\{\{more\}\}/mi,"")
	end
end
