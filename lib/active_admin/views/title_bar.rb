module ActiveAdmin
  module Views
    class TitleBar < Component

      def build(title, action_items)
        @title = title
        @action_items = action_items
        build_breadcrumb
        div class: 'row' do
          div class: 'col-lg-7' do
            build_titlebar_left
          end
          div class: 'col-lg-5' do
            build_titlebar_right
          end
        end
        hr
      end

      private

      def build_titlebar_left
        build_title_tag
      end

      def build_titlebar_right
        div class: 'pull-right' do
          build_action_items
        end
      end

      def build_breadcrumb(separator = "/")
        breadcrumb_config = active_admin_config && active_admin_config.breadcrumb
        links = if breadcrumb_config.is_a?(Proc)
          instance_exec(controller, &active_admin_config.breadcrumb)
        elsif breadcrumb_config.present?
          breadcrumb_links
        end
        return unless links.present? && links.is_a?(::Array)
        ol class: "breadcrumb" do
          links.each do |link|
            li do
              text_node link
            end
          end
        end
      end

      def build_title_tag
        h2(@title, id: 'page_title')
      end

      def build_action_items
        insert_tag(view_factory.action_items, @action_items) if @action_items.any?
      end

    end
  end
end
