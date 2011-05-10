module BlogsPlugin
	module ApplicationHelperGlobalPatch
    def self.included(base) # :nodoc:    
      base.send(:include, InstanceMethods)     
      base.class_eval do      
				include TagsHelper
        unloadable
        alias_method_chain :link_to_if_authorized, :global
        alias_method_chain :authorize_for, :global
      end
    end
    module InstanceMethods    
			def link_to_if_authorized_with_global(name, options = {}, html_options = nil, *parameters_for_method_reference)
				link_to(name, options.delete_if{|k,v| k == :global}, html_options, *parameters_for_method_reference) if authorize_for_with_global(options[:controller] || params[:controller], options[:action], options[:global])
			end
			def authorize_for_with_global(controller, action, global = false)
				User.current.allowed_to?({:controller => controller, :action => action}, @project, {:global => global})
			end
    end
  end
end
