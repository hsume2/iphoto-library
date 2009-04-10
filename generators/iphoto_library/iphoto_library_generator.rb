class IphotoLibraryGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      if args.blank? or args.size != 2
        puts usage_message
      else
        d = Dir.pwd
        Dir.chdir(args[0]) # removes trailing slashes, checks if dir is valid
        library = Dir.pwd
        Dir.chdir(d)
        
        server = args[1][/.*[^\/$]/] # removes trailing slashes
        
        m.template 'iphoto.yml', 'config/iphoto.yml', :assigns => { :library => library, :server => server }
        m.migration_template 'create_iphoto_library.rb', 'db/migrate', :migration_file_name => 'create_iphoto_library'
      end
    end
  end
end
