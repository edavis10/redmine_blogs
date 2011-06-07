module RedmineBlogs
  module Hooks
    class ViewAccountLeftMiddleHook < Redmine::Hook::ViewListener
      def view_account_left_middle(context={})
        if User.current.allowed_to?(:view_blogs, nil, {:global => true})
          user = context[:user]
          @blogs = Blog.all(:limit => 5,
                            :order => "#{Blog.table_name}.created_on DESC",
                            :conditions => ["author_id = (?)", user.id])

          return context[:controller].send(:render_to_string, {
                                             :partial => 'blogs/user_page',
                                             :locals => {:blogs => @blogs, :user => user}
                                           })
        else
          return ""
        end

      end
    end
  end
end
