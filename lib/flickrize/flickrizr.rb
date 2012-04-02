require 'active_support/concern'

module Flickrize
  module Flickrizr
    extend ActiveSupport::Concern
 
    included do
    end
    
    module ClassMethods
      def flickrizr(options={}, &block)
        cattr_accessor :flickr_id, :set_id, :gallery_id, :image
        self.flickr_id = (options[:flickr_id] || :flickr_id).to_s
        self.set_id = (options[:set_id] || :set_id).to_s
        self.gallery_id = (options[:gallery_id] || :gallery_id).to_s
        self.image = (options[:image] || :image).to_s
        self.image_url = (options[:image_url] || :image_url).to_s
        before create do |record|
          if !self.class.image.blank?
            flickr_image = self.class.image.path
            write_attribute(self.class.flickr_id, flickr.upload_photo(flickr_image, :title => self[:title], :description => self[:description], :is_public => self[:is_public], :hidden => self[:hidden]))            
          else !self.class.image_url.blank?
            open(self.class.image_url, 'rb') do |image_url|
              flickr_image = Tempfile.new(['flickrup', '.jpg']) 
              begin
                while !image_url.eof
                  flickr_image.binmode.write(image_url.read(4096))
                end
                flickr_image.rewind
                write_attribute(self.class.flickr_id, flickr.upload_photo(flickr_image, :title => self[:title], :description => self[:description], :is_public => self[:is_public], :hidden => self[:hidden]))
              ensure
                flickr_image.close
                flickr_image.unlink
              end
            end
          end
          flickr.photosets.addPhoto :photoset_id => self.class.set_id, :photo_id => self.class.flickr_id unless self.class.set_id.blank?
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Flickrize::Flickrizr 