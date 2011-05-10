module RedmineBlogs
  module Patches
    module CommentPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def attachments
          commented.respond_to?(:attachments) ? commented.attachments : nil
        end
      end
    end
  end
end
