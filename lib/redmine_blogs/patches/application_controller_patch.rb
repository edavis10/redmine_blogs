module RedmineBlogs
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          helper :tags

        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end
