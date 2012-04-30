module Flickrize
  module Setizr
    require 'active_support/concern'
    require 'flickraw'
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods

      def setizr(options={})
        options.reverse_merge! set_id: :set_id, title: :title, description: :description, url: :set_url, primary_photo_id: :primary_photo_id
        
        attr_protected options[:set_id], options[:url]
        attr_accessor options[:primary_photo_id]

        before_create do |record|
          begin
            set = flickr.photosets.create title: record.send(options[:title]), description: record.send(options[:description]), primary_photo_id: record.send(options[:primary_photo_id])
            record.send("#{options[:set_id]}=", set.id)
            record.send("#{options[:url]}=", set.url)
          rescue Exception => e
            record.errors.add options[:set_id], e
            return false
          end
        end
        
        before_update do |record|
          begin
            flickr.photosets.editMeta photoset_id: record.send(options[:set_id]), title: record.send(options[:title]), description: record.send(options[:description])
          rescue Exception => e
            record.errors.add options[:set_id], e
            return false
          end
        end
        
        before_destroy do |record|
          begin
            flickr.photosets.delete photoset_id: record.send(options[:set_id])
          rescue Exception => e
            record.errors.add options[:set_id], e
            return false
          end
        end
      end
    end
  end
end
require 'active_record'
ActiveRecord::Base.send :include, Flickrize::Setizr
