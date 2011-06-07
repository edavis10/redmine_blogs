require File.dirname(__FILE__) + '/../../../test_helper'

class RedmineBlogs::Hooks::ViewAccountLeftMiddleTest < ActionController::IntegrationTest
  include Redmine::Hook::Helper

  context "when logged in as a user without View Blogs permission" do
    setup do
      @user = User.generate!(:password => 'test', :password_confirmation => 'test').reload
      @project = Project.generate!
      @blog1 = Blog.generate!(:author => @user).reload
      @role = Role.generate(:permissions => [])
      User.add_to_project(@user, @project, @role)
      login_as(@user.login, 'test')
      visit_home
    end
    
    should "not see any blogs" do
      click_link @user.login
      assert_equal "/users/#{@user.id}", current_path
      assert has_css? "#blogs", :count => 0
    end
    
  end

  context "when logged in as a user with View Blogs permission" do
    setup do
      @user = User.generate!(:password => 'test', :password_confirmation => 'test').reload
      @project = Project.generate!
      @blog1 = Blog.generate!(:author => @user).reload
      @role = Role.generate(:permissions => [:view_blogs])
      User.add_to_project(@user, @project, @role)
      login_as(@user.login, 'test')
      visit_home
    end

    should "see the blogs section" do
      click_link @user.login
      assert has_css? "#blogs"
    end
    
    should "see the last 5 blog posts" do
      @blog2 = Blog.generate!(:author => @user).reload
      @blog3 = Blog.generate!(:author => @user).reload
      @blog4 = Blog.generate!(:author => @user).reload
      @blog5 = Blog.generate!(:author => @user).reload
      @blog6 = Blog.generate!(:author => @user).reload

      click_link @user.login
      assert_response :success
      assert has_css? ".blog", :count => 5
      assert has_css? "h3", :text => /#{@blog2.title}/
      assert has_css? "h3", :text => /#{@blog3.title}/
      assert has_css? "h3", :text => /#{@blog4.title}/
      assert has_css? "h3", :text => /#{@blog5.title}/
      assert has_css? "h3", :text => /#{@blog6.title}/
      assert has_css? "h3", :text => /#{@blog1.title}/, :count => 0
    end
    
    should "see a link to the main blogs page for the user" do
      click_link @user.login
      
      assert has_link? "All blog posts"
    end
    
  end
  
end
