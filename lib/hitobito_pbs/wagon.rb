module HitobitoPbs
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    # config.autoload_paths += %W( #{config.root}/lib )

    config.to_prepare do
      # extend application classes here
      Group.send  :include, Group::Generic
    end

    initializer "pbs.add_settings" do |app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end
  end
end
