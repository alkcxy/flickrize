module Flickrize
  def self.initialize_with options
    require 'flickraw'
    #require 'will_paginate'
    FlickRaw.api_key = options[:api_key]
    FlickRaw.shared_secret = options[:shared_secret]
    flickr.auth.checkToken :auth_token => options[:auth_token]
  end
  class Base
    attr_accessor :id, :image, :title, :description, :type    
    cattr_accessor :per_page
    @@per_page = 10
    
    def initialize(attributes = {})
      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
      @attributes = attributes
    end
    
    # usefull for using validations
    def read_attribute_for_validation(key)
      @attributes[key]
    end
   
    def to_key
    end
    
    def persistence
    end
   
    def save
      if self.valid?
        self.title ||= self.image.original_filename
        self.description ||= self.image.original_filename
        hidden = self.hidden || 2
        begin
          self.id = flickr.upload_photo self.image.path, :title => self.title, :description => self.description, :is_public => 0, :hidden => hidden
          flickr.photosets.addPhoto :photoset_id => self.type, :photo_id => self.id unless self.type.blank?
          return true
        rescue Exception => e
          errors.add :image, e
        end
      end
      return false
    end
    
    def self.find id
      flickr.photos.getInfo(:photo_id => id)
    end
    
    def self.find_by set, pagination={}
      pagination.reverse_merge! :page => 1, :per_page => (self.per_page || 500)
      begin
        require 'will_paginate/array'
        total_entries = flickr.photosets.getInfo(:photoset_id => set).count_photos
        WillPaginate::Collection.create pagination[:page] || 1, pagination[:per_page], total_entries do |pager| 
          pager.replace(flickr.photosets.getPhotos(:photoset_id => set, :page => pagination[:page], :per_page => pagination[:per_page]).photo)
        end
      rescue
      end
    end
    
    def self.find_by_set title, pagination={}
      pagination.reverse_merge! :page => 1, :per_page => (self.per_page || 500)
      begin
        list = flickr.photosets.getList
        id = ''
        list.each do |set_info|
          id = set_info['id'] if set_info['title'] == title
        end
        self.find_by id, :per_page => pagination[:per_page], :page => pagination[:page]
      rescue
      end
    end
    
    def self.find_random_by_set id, number_of_photos=1
      number_of_photos -= 1
      if number_of_photos <= 0
        self.find_by(id, :page => 1, :per_page => 500).shuffle.slice(0)
      else
        self.find_by(id, :page => 1, :per_page => 500).shuffle.slice(0..number_of_photos)
      end
    end
    
    def self.get_all_contexts id
      flickr.photos.getAllContexts(:photo_id => id)
    end
    
    def self.find_not_in_set pagination={}
      pagination.reverse_merge! :page => 1, :per_page => (self.per_page || 500)
      begin
        total_entries = flickr.photos.getNotInSet.count
        WillPaginate::Collection.create pagination[:page] || 1, pagination[:per_page], total_entries do |pager| 
          pager.replace(flickr.photos.getNotInSet(:page => pagination[:page], :per_page => pagination[:per_page]).to_a)
        end
      rescue
      end
    end
    
    # used on development mode when application starts offline
    # otherwise flickr auto logged on with an initializer file or whatever
    def self.flickr_auto_login
      begin
        flickr.auth.checkToken :auth_token => FLICKR_AUTH_CHECK_TOKEN
      rescue
      end
    end
  end
  module ActionView
    require 'will_paginate/view_helpers/action_view'
    include WillPaginate::ActionView
  end
end
