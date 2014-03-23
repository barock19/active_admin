module ActiveAdmin
  module Views
    class Header < Component
      def tag_name
        'nav'
      end

      def build(namespace, menu)
        super(class: 'navbar navbar-default navbar-static-top', id: 'top', role: 'banner', style: 'margin-bottom: 0')
        @namespace = namespace
        @menu = menu
        @utility_menu = @namespace.fetch_menu(:utility_navigation)
        div class: 'navbar-header' do
          build_navbar_toogle
          build_site_title
        end
          # build_global_navigation
          build_utility_navigation
      end

      def build_navbar_toogle
        button type: 'button',class: 'navbar-toggle', 'data-toggle'=>"collapse", 'data-target'=>".navbar-collapse"
        span 'Toggle Navigation', class: 'sr-only' 
      end



      def build_site_title
        insert_tag view_factory.site_title, @namespace
      end

      def build_global_navigation
        insert_tag view_factory.global_navigation, @menu, class: 'nav navbar-nav'
      end

      def build_utility_navigation
        insert_tag view_factory.utility_navigation, @utility_menu, id: "utility_nav", class: 'nav navbar-top-links navbar-right'
      end
      private

      # def opening_tag; '' ; end
      # def closing_tag; '' ; end
    end
  end
end
