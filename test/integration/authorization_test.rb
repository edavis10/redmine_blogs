require 'test_helper'

class AuthorizationTest < ActionController::IntegrationTest
  def setup
    @user = User.generate!(:password => 'test', :password_confirmation => 'test').reload
    @user2 = User.generate!.reload
    @project = Project.generate!
    @blog1 = Blog.generate!(:author => @user)
    @blog2 = Blog.generate!(:author => @user2)
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

      assert has_no_link?("Delete")
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
    should "not be able to see the Blogs menu item"
    should "not be able to see the list of user blogs"
    should "not be able to view a blog post"
    should "not be able to comment on a blog post"
    should "not be able to add a new blog post"
    should "not be able to delete a blog post"
    should "not be able to edit a blog post"
    should "not be able to delete a blog comment"
  end

  context "with manage blogs and view blogs permissions enabled" do
    should "be able to see the Blogs menu item"
    should "be able to see the list of user blogs"
    should "be able to view a blog post"
    should "be able to comment on a blog post"
    should "be able to add a new blog post"
    should "be able to delete a blog post"
    should "be able to edit a blog post"
    should "be able to delete a blog comment"
  end
end
