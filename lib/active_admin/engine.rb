module ActiveAdmin
  class Engine < ::Rails::Engine
    initializer "ActiveAdmin precompile hook", group: :all do |app|
      app.config.assets.precompile += %w(active_admin.js active_admin.css admin-lte/base.css admin-lte/base.js)
    end
  end
end
