class Comment < ActiveRecord::Base
  def attachments
    commented.respond_to?(:attachments) ? commented.attachments : nil
  end
end
