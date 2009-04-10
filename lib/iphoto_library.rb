=begin rdoc
  Makes settings stored in config/iphoto.yml accessible to the application.
=end
class IphotoLibrary  
  @@iphoto_config_path = "#{RAILS_ROOT}" + File::Separator + "config" + File::Separator + "iphoto.yml"
  @@iphoto_config = nil

  class << self
    attr_reader :path, :server, :albumdata_path # :nodoc:

    # Loads iphoto.yml for IphotoLibrary.path, IphotoLibrary.server, and IphotoLibrary.albumdata_path
    def load_config
      if @@iphoto_config.nil?
        puts "[iphoto library] Reading #{@@iphoto_config_path}"
        begin
          iphoto_config_file = File.read(@@iphoto_config_path)
        rescue Exception => e
          raise "\nNo iphoto.yml - #{@@iphoto_config_path}\n\nExecute:\n\tscript/generate iphoto_library LibraryPath Server\n\n"
        end
        @@iphoto_config = YAML.load(iphoto_config_file)[RAILS_ENV]
      end
    end

    # The path to the iPhoto library
    def path
      load_config
      @@path = @@iphoto_config['library']
    end

    # The server to serve assets behind
    def server
      load_config
      @@server = @@iphoto_config['server']
    end
    
    # The path to AlbumData.xml in the iPhoto Library
    def albumdata_path
      File.join(self.path, 'AlbumData.xml')
    end
    
    # Checks if the iPhoto Library is valid
    def albumdata
      unless File.directory?(self.path)
        raise 'iPhoto Library is invalid'
      end

      unless File.exists?(albumdata_path)
        raise 'iPhoto Library AlbumData.xml is invalid'
      end
      
      albumdata_path
    end
  end
  
  load_config
  albumdata
end