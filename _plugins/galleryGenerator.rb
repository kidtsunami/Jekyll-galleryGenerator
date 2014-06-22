require 'fileutils'
require 'RMagick'

module Jekyll

  # overrides StaticFile to allow different directories between the source and destination
  class GalleryFile < StaticFile    
    attr_accessor :thumbs

    # the path of the source file
    def path
      File.join(@base, @name)
    end

    # the destination within the site
    def relative_path
      @relative_path ||= File.join(@dir, @name)
    end    

    # adds thumbs for thumb GalleryFiles
    def to_liquid
      super_liquid = super
      super_liquid['thumbs'] = thumbs
      super_liquid
    end  
  end

  # for inserting galleries into the site payload
  class Site
    attr_accessor :galleries
    
    alias orig_site_payload site_payload
    def site_payload
        h = orig_site_payload
        payload = h["site"]
        payload["galleries"] = galleries
        h["site"] = payload
        h
    end
  end

  # inserting the gallery attribute into the liquid rendering of a post
  class Post
    attr_accessor :gallery

    def to_liquid(attrs = ATTRIBUTES_FOR_LIQUID)
      super(attrs + %w[
        gallery
      ])
    end 
  end

  # generates galleries of GalleryFiles and adds them as StaticFiles
  class GalleryGenerator < Generator
    safe true
    priority :lowest

    def generate(site)
      site.galleries = {}

      @gallery_thumbs = site.config['gallery_thumbs']
      if not @gallery_thumbs
        puts 'no gallery_thumbs in config, no thumbnails will be generated'
        @gallery_thumbs = []
      end

      if not File.directory?(File.join(site.config['source'], '_galleries'))
        puts '_galleries directory missing, no galleries to process'
      end

      Dir.glob(File.join(site.config['source'], '_galleries','**')).each do |gallery_dir|        
        gallery_name = File.basename(gallery_dir)
        gallery_url = "/galleries/#{gallery_name}/"
        site.galleries[gallery_name] = []


        for thumb_size in @gallery_thumbs
          thumb_dir = "#{gallery_dir}/#{thumb_size}"
          FileUtils.mkdir_p(thumb_dir)
        end

        # for each gallery file
        Dir.glob(File.join(gallery_dir, '*.{png,jpg,jpeg,gif}')).each do |image_file|
          image_name = File.basename(image_file)

          gallery_file = GalleryFile.new(site, gallery_dir, CGI.unescape(gallery_url), File.basename(image_file))
          
          # create and associate thumbs for Gallery file
          gallery_file.thumbs = {}
          for thumb_size_string in @gallery_thumbs
            thumb_dir = "#{gallery_dir}/#{thumb_size_string}"
            thumb_url = "#{gallery_url}#{thumb_size_string}/"          
            thumb_size = get_image_size_from_string(thumb_size_string)            
            thumb_name = File.join(thumb_dir, image_name)
            
            if !File.exists?(thumb_name)
              gallery_image = Magick::Image.read(image_file).first
              thumb_image = gallery_image.resize_to_fill!(thumb_size.width, thumb_size.height)  
              thumb_image.write(thumb_name)
              thumb_image.destroy!
            end

            thumb_file = GalleryFile.new(site, thumb_dir, CGI.unescape(thumb_url), File.basename(thumb_name))            
            site.static_files << thumb_file
            gallery_file.thumbs[thumb_size_string] = thumb_file
          end

          # adding to site as a static file copies it to the site directory
          site.static_files << gallery_file

          # add to site galleries for easy payload access
          site.galleries[gallery_name] << gallery_file
        end
      end

      # associate galleries with posts by the same name
      site.posts.each do |post|        
        post_gallery_name = post.name.chomp(File.extname(post.name))
        
        if site.galleries.has_key?(post_gallery_name)
          post.gallery = site.galleries[post_gallery_name]
        end
      end
    end

    ImageSize = Struct.new :width, :height

    def get_image_size_from_string(image_size_string)
      image_size = nil
      image_size_strings = image_size_string.split(/\s*\D+\s*/) # non-digits surrounded by any amount of white space

      if image_size_strings.length == 2
        begin
          image_size = ImageSize.new(Integer(image_size_strings[0]), Integer(image_size_strings[1]))
        rescue ArgumentError, TypeError
          puts 'come on now give me something to work with here, 50x20 would work 50 by 20 would work, come on'
        end
      else
        puts 'Sorry, there are an incorrect amount of digit tokens (#{image_size_strings.length}) in #{image_size_string} to process'      
      end
      return image_size
    end

    def get_files_to_resize(site)
      files_to_resize = []

      Dir.glob(File.join(@galleries_dir, "**")).each do |gallery_dir|

      end

      Dir.glob(File.join(@gallery_dir, "**", "*.{png,jpg,jpeg,gif}")).each do |image_file|
        name = File.basename(image_file).sub(File.extname(image_file), "-thumb#{File.extname(image_file)}")
        
      end
    end
  end
end