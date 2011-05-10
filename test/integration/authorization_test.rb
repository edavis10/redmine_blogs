require 'test_helper'

class AuthorizationTest < ActionController::IntegrationTest
  def setup
    @user = User.generate!(:password => 'test', :password_confirmation => 'test').reload
    @user2 = User.generate!.reload
    @project = Project.generate!
    @blog1 = Blog.generate!(:author => @user).reload
    @blog2 = Blog.generate!(:author => @user2).reload
  end
  
  context "with view blogs permission enabled only" do
    setup do
      @role = Role.generate(:permissions => [:view_blogs])
      User.add_to_project(@user, @project, @role)
      login_as(@user.login, 'test')
      visit_home
    end
    
    should "be able to see the Blogs menu item" do
      assert find("#top-menu li a", :text => /Blogs/)
    end

    should "be able to see the list of user blogs" do
      click_link "Blogs"
      assert_response :success

      assert find("table.blogs a", :text => @user2.name)
    end
    
    should "be able to view a blog post" do
      click_link "Blogs"
      assert_response :success

      click_link @blog1.title
      assert_response :success
      
    end
    
    should "not be able to comment on a blog post" do
      click_link "Blogs"
      assert_response :success

      click_link @blog1.title
      assert_response :success
      
      assert has_no_link?("Add a comment")
    end
    
    should "not be able to add a new blog post" do
      click_link "Blogs"
      assert_response :success

      assert has_no_link?("New post")
      assert has_no_css?("#add-blog")
    end
    
    should "not be able to delete a blog post" do
      click_link "Blogs"
      assert_response :success

      click_link @blog1.title
      assert_response :success

      assert has_no_link?("Delete")
    end
    
    should "not be able to edit a blog post" do
      click_link "Blogs"
      assert_response :success

      click_link @blog1.title
      assert_response :success

      assert has_no_link?("Edit")
    end
    
    should "not be able to delete a blog comment" do
      click_link "Blogs"
      assert_response :success

      click_link @blog1.title
      assert_response :success

      within("#comments") do
        assert has_no_link?("Delete")
      end

    end
  end

  context "with view blogs permission disabled" do
    setup do
      @role = Role.generate(:permissions => [])
      User.add_to_project(@user, @project, @role)
      login_as(@user.login, 'test')
      visit_home
    end

    should "not be able to see the Blogs menu item" do
      assert has_no_css?("#top-menu li a.blogs", :text => /Blogs/)
    end
    
    should "not be able to see the list of user blogs" do
      visit "/blogs"
      assert_forbidden
    end
    
    should "not be able to view a blog post" do
      visit "/blogs/show/#{@blog1.id}"
      assert_forbidden
    end
    
    should "not be able to comment on a blog post" do
      page.driver.post "/blogs/add_comment/#{@blog1.id}", {}
      assert_forbidden
    end
    
    should "not be able to add a new blog post" do
      page.driver.post "/blogs/new", {}
      assert_forbidden
    end
    
    should "not be able to delete a blog post" do
      page.driver.post "/blogs/destroy/1", {}
      assert_forbidden
    end
    
    should "not be able to edit a blog post" do
      page.driver.post "/blogs/edit/1", {}
      assert_forbidden
    end

    should "not be able to delete a blog comment"
  end

  context "with manage blogs and view blogs permissions enabled" do
    setup do
      @role = Role.generate(:permissions => [:view_blogs, :comment_blogs, :manage_blogs])
      User.add_to_project(@user, @project, @role)
      login_as(@user.login, 'test')
      visit_home
    end

        should "be able to see the Blogs menu item" do
      assert find("#top-menu li a", :text => /Blogs/)
    end

    should "be able to see the list of user blogs" do
      click_link "Blogs"
      assert_response :success

      assert find("table.blogs a", :text => @user2.name)
    end
    
    should "be able to view a blog post" do
      click_link "Blogs"
      assert_response :success

      click_link @blog1.title
      assert_response :success
      
    end
    
    should "be able to comment on a blog post" do
      click_link "Blogs"
      assert_response :success

      click_link @blog1.title
      assert_response :success
      
      # TODO: add comment is JS-only link
      assert_difference("Comment.count") do
        fill_in "comment_comments", :with => 'A comment'
        click_button "Add"
        assert_response :success
      end
    end
    
    should "be able to add a new blog post" do
      click_link "Blogs"
      assert_response :success

      assert_difference("Blog.count") do
        fill_in "Title", :with => "Test manage"
        fill_in "Summary", :with => "A summary"
        fill_in "Tags list", :with => "some tags, blog, test"
        fill_in "Description", :with => "This *is* the description"
        click_button "Create"
        assert_response :success
      end

      blog = Blog.last
      assert_equal "Test manage", blog.title
      assert_equal "A summary", blog.summary
      assert_equal "This *is* the description", blog.description
      assert_equal @user, blog.author
      ['some tags', 'blog', 'test'].each do |tag|
        assert blog.tag_list.include?(tag), "Missing tag on blog: #{tag}"
      end
    end
    
    should "be able to delete a blog post" do
      click_link "Blogs"
      assert_response :success

      click_link @blog1.title
      assert_response :success

      assert_difference("Blog.count", -1) do
        click_link "Delete"
      end
      assert_response :success
    end
    
    should "be able to edit a blog post" do
      click_link "Blogs"
      assert_response :success

      click_link @blog1.title
      assert_response :success

      # click_link "Edit" # TODO: JS-only link
      fill_in "Title", :with => "Changed"
      click_button "Save"

      assert_equal "Changed", @blog1.reload.title
    end
    
    should "be able to delete a blog comment" do
      click_link "Blogs"
      assert_response :success

      click_link @blog1.title
      assert_response :success

      # TODO: add comment is JS-only link
      assert_difference("Comment.count") do
        fill_in "comment_comments", :with => 'A comment'
        click_button "Add"
        assert_response :success
      end

      assert_difference("Comment.count", -1) do
        within("#comments") do
          click_link "Delete"
          assert_response :success
        end
      end

    end
  end
end
