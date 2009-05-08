module Iphoto
  class Photo < Media

    def public_path(file_name)
      "/photos/#{self.id}/#{file_name}.jpg"
    end
    
    def output_path(file_name)
      File.join(RAILS_ROOT, "public", "photos", self.id.to_s, "#{file_name}.jpg")
    end

    # TODO add thumbnail generator worker
    def on_demand(width, height)
      dims = "#{width}x#{height}"

      public_path = self.public_path(dims)
      output_path = self.output_path(dims)

      if File.exists?(output_path)
        logger.info "[iphoto library] Thumbnail hit at #{public_path}"
      else
        FileUtils.mkdir_p(File.dirname(output_path))

        unless defined? MiniMagick
          logger.debug "[iphoto library] Requiring MiniMagick"
          require 'mini_magick'
        end

        image = MiniMagick::Image.from_file(image_path(true))
        image.resize dims
        image.write(output_path)
        FileUtils.chmod 0755, output_path

        logger.info "[iphoto library] Created thumbnail at #{output_path}"
      end

      public_path
    end
  end
end
