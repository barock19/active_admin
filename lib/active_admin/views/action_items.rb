module ActiveAdmin
  module Views

    class ActionItems < ActiveAdmin::Component

      def build(action_items)
        action_items.each do |action_item|
          ie = instance_exec(&action_item.block)
          span class: "action_item btn btn-sm btn-default" do
            ie
          end unless ie.blank?
        end
      end

    end

  end
end
