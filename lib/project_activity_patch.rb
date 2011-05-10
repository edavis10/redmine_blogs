class Project < ActiveRecord::Base
  def self.allowed_to_condition(user, permission, options={})
    statements = []
    base_statement = "#{Project.table_name}.status=#{Project::STATUS_ACTIVE}"
    if perm = Redmine::AccessControl.permission(permission)
      unless perm.project_module.nil?
        # If the permission belongs to a project module, make sure the module is enabled
        #base_statement << " AND EXISTS (SELECT em.id FROM #{EnabledModule.table_name} em WHERE em.name='#{perm.project_module}' AND em.project_id=#{Project.table_name}.id)"
      end
    end
    if options[:project]
      project_statement = "#{Project.table_name}.id = #{options[:project].id}"
      project_statement << " OR (#{Project.table_name}.lft > #{options[:project].lft} AND #{Project.table_name}.rgt < #{options[:project].rgt})" if options[:with_subprojects]
      base_statement = "(#{project_statement}) AND (#{base_statement})"
    end
    if user.admin?
      # no restriction
    else
      statements << "1=0"
      if user.logged?
        statements << "#{Project.table_name}.is_public = #{connection.quoted_true}" if Role.non_member.allowed_to?(permission)
        allowed_project_ids = user.memberships.select {|m| m.role.allowed_to?(permission)}.collect {|m| m.project_id}
        statements << "#{Project.table_name}.id IN (#{allowed_project_ids.join(',')})" if allowed_project_ids.any?
      elsif Role.anonymous.allowed_to?(permission)
        # anonymous user allowed on public project
        statements << "#{Project.table_name}.is_public = #{connection.quoted_true}" 
      else
        # anonymous user is not authorized
      end
    end
    statements.empty? ? base_statement : "((#{base_statement}) AND (#{statements.join(' OR ')}))"
  end
end