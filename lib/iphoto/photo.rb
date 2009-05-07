module Iphoto
  class Photo < Media

    def on_demand(width, height)
      dims = "#{width}x#{height}"

      public_path = "/photos/#{self.id}/#{dims}.jpg"
      output_path = File.join(RAILS_ROOT, "public", "photos", self.id.to_s, "#{dims}.jpg")

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
