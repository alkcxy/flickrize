module Flickrize
  module Flickrizr
    require 'active_support/concern'
    require 'flickraw'
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods

      def flickrizr(options={}, &block)
        options.reverse_merge! flickr_id: :flickr_id, image: :image, server: :server, secret: :secret, originalsecret: :originalsecret, originalformat: :originalformat, set_ids: :set_ids, title: :title, description: :description, hidden: :hidden, is_public: :is_public, farm: :farm 
        class_attribute :iop
        attr_accessor options[:image], options[:set_ids]
        self.iop = options
        #options.each do |k, v|
        #  attr_accessor v.to_sym if !instance_methods.index { |m| m == v.to_sym }
        #end

        before_create do |record|
          public = record.send(options[:is_public]) ? 1 : 0
          if !record.send(options[:image]).blank? && record.send(options[:image]).respond_to?(:path)
            flickr_image = record.send(options[:image])
            begin
              flickr_id = flickr.upload_photo(flickr_image.path, :title => record.send(options[:title]), :description => record.send(options[:description]), :is_public => public, :hidden => record.send(options[:hidden]))
            rescue Exception => e
              record.errors.add options[:image], e
            end
          elsif !record.send(options[:image]).blank?
            require 'open-uri'
            open(record.send(options[:image]), 'rb') do |image_url|
              flickr_image = Tempfile.new(['flickrup', '.jpg']) 
              begin
                flickr_image.binmode.write(image_url.read(4096)) while !image_url.eof
                flickr_image.rewind
                begin
                  flickr_id = flickr.upload_photo(flickr_image.path, :title => record.send(options[:title]), :description => record.send(options[:description]), :is_public => public, :hidden => record.send(options[:hidden]))
                rescue Exception => e
                  record.errors.add options[:image], e
                end
              ensure
                flickr_image.close
                flickr_image.unlink
              end
            end
          end
          if !flickr_id.blank?
            record.send("#{options[:flickr_id]}=", flickr_id)
            begin
              flickr_obj = flickr.photos.getInfo(:photo_id => flickr_id)
              record.send("#{options[:farm]}=", flickr_obj.farm)
              record.send("#{options[:server]}=", flickr_obj.server)
              record.send("#{options[:secret]}=", flickr_obj.secret)
              record.send("#{options[:originalsecret]}=", flickr_obj.originalsecret)
              record.send("#{options[:originalformat]}=", flickr_obj.originalformat)
              record.send(options[:set_ids]).each do |k, set_id|
                flickr.photosets.addPhoto :photoset_id => set_id, :photo_id => record.send(options[:flickr_id])
              end unless record.send(options[:set_ids]).blank?
            rescue Exception => e
              flickr.photos.delete photo_id: flickr_id
              record.errors.add options[:image], e
            end
            return false if record.errors.any?
          else
            return false
          end
        end
        
        before_update do |record|
          begin
            flickr.photos.setMeta photo_id: record.send(options[:flickr_id]), title: record.send(options[:title]), description: record.send(options[:description])
            public = record.send(options[:is_public]) ? 1 : 0
            flickr.photos.setPerms photo_id: record.send(options[:flickr_id]), is_public: public, is_family: 0, is_friend: 0, perm_comment: 0, perm_addmeta: 0
            hidden = record.send(options[:hidden]) == 2 ? 0 : 1
            flickr.photos.setSafetyLevel photo_id: record.send(options[:flickr_id]), hidden: hidden
            context = flickr.photos.getAllContexts(photo_id: record.send(options[:flickr_id]))
            unless context.to_hash.empty?
              sets = context.set
              set_ids = record.send(options[:set_ids])
              sets.each do |set|
                ps = set_ids.blank? ? nil : set_ids.key(set.id) 
                if ps.blank?
                  flickr.photosets.removePhoto photo_id: record.send(options[:flickr_id]), photoset_id: set.id
                else
                  set_ids.delete ps
                end
              end
              set_ids.each do |k, set_id|
                flickr.photosets.addPhoto photo_id: record.send(options[:flickr_id]), photoset_id: set_id
              end
            end
            flickr_obj = flickr.photos.getInfo(:photo_id => record.send(options[:flickr_id]))
            record.send("#{options[:farm]}=", flickr_obj.farm)
            record.send("#{options[:server]}=", flickr_obj.server)
            record.send("#{options[:secret]}=", flickr_obj.secret)
            record.send("#{options[:originalsecret]}=", flickr_obj.originalsecret)
            record.send("#{options[:originalformat]}=", flickr_obj.originalformat)
          rescue Exception => e
            record.errors.add options[:image], e
            return false
          end
        end
        
        before_destroy do |record|
          begin
            flickr.photos.delete photo_id: record.send(options[:flickr_id])
          rescue Exception => e
            record.errors.add options[:image], e
            return false
          end
        end
      end
    end
    def url
      url_
    end
    def method_missing(sym, *args, &block)
      if sym.to_s.start_with? "url_"
        url_suffix = sym.to_s.sub(/^url/,"")
        format = "jpg"
        secret = self.send(self.iop[:secret]) 
        if sym.to_s.end_with? "_o"
          format = self.send(self.iop[:originalformat])
          secret = self.send(self.iop[:originalsecret])
        elsif sym.to_s.end_with? "_"
          url_suffix = ""
        end
        PHOTO_SOURCE_URL % [self.send(self.iop[:farm]), self.send(self.iop[:server]), self.send(self.iop[:flickr_id]), secret, url_suffix, format]
      else
        super
      end
    end
    private
    PHOTO_SOURCE_URL = 'http://farm%s.static.flickr.com/%s/%s_%s%s.%s'.freeze
  end
end
require 'active_record'
ActiveRecord::Base.send :include, Flickrize::Flickrizr
 
