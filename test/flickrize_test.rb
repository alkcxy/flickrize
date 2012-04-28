require 'test/unit'
require 'flickrize/flickrizr'

class FlickrizeTest < ActiveSupport::TestCase
  
  test 'respond_to_flickrizr' do
    assert_respond_to(Photo, :flickrizr)
    assert_respond_to(Image, :flickrizr)
  end
  
  # test attr_accessor inside flickrizr
  test 'photo_has_image_attrs' do
    p = Photo.new
    assert_respond_to(p, :image)
  end

  # test attr_accessor inside flickrizr with custom virtual attributes
  test 'image_has_image_attrs' do
    i = Image.new
    assert_respond_to(i, :i)
  end
  
  #test before_create and before_update and before_destroy inside flickrizr
  test 'before_create_set_flickr_id_with_uploaded_image' do
    image = fixture_file_upload('rails.png', 'image/png')
    set_ids = { "0" => 72157627611253919, "1" => 72157627735215906 }
    p = Photo.new(image: image, title: "titolo", description: "descrizione", is_public: 0, hidden: 2, set_ids: set_ids)
    assert(p.save, "non ha salvato")
    assert_not_nil(p.flickr_id)
    # rimuovere un set
    set_ids = { "0" => 72157627611253919 }
    p.update_attributes(title: "titolo2", description: "description2", set_ids: set_ids)
    # aggiungere un set
    set_ids = { "0" => 72157627611253919, "1" => 72157627735215906 }
    p.update_attributes(title: "titolo3", description: "description3", set_ids: set_ids)
    a = flickr.photos.getAllContexts(photo_id: p.flickr_id).set.index{|s| s.id == "72157627735215906"}
    assert_not_nil(a, "set non trovato")
    assert(p.destroy, "foto non cancellata")
    assert_nil(Photo.find_by_flickr_id(p.flickr_id))
  end

  #test before_create and before_update and before_destroy inside flickrizr
  test 'before_create_set_flickr_id_with_image_url' do
    image = "http://rubyonrails.org/images/rails.png"
    p = Photo.new(image: image, title: "titolo", description: "descrizione", is_public: 0, hidden: 2)
    assert(p.save, "non ha salvato")
    assert_not_nil(p.flickr_id)
    p.update_attributes(title: "titolo2", description: "description2")
    assert_equal(p.title, "titolo2")
    assert(p.destroy, "foto non cancellata")
    assert_nil(Photo.find_by_flickr_id(p.flickr_id))
  end
  
  test 'photo_url' do
    image = "http://rubyonrails.org/images/rails.png"
    p = Photo.new(image: image, title: "titolo", description: "descrizione", is_public: 0, hidden: 2)
    p.save
    url_m = 'http://farm%s.static.flickr.com/%s/%s_%s%s.%s' % [p.farm, p.server, p.flickr_id, p.secret, "_m", "jpg"]
    url = 'http://farm%s.static.flickr.com/%s/%s_%s%s.%s' % [p.farm, p.server, p.flickr_id, p.secret, "", "jpg"]
    url_o = 'http://farm%s.static.flickr.com/%s/%s_%s%s.%s' % [p.farm, p.server, p.flickr_id, p.originalsecret, "_o", p.originalformat]
    assert_equal(p.url_m, url_m)
    assert_equal(p.url, url)
    assert(p.url_o, url_o)
    assert(p.destroy, "foto non cancellata")
  end
  
  test 'should_have_visibility' do
    image = "http://rubyonrails.org/images/rails.png"
    is_public = 0
    hidden = 2
    p = Photo.new(image: image, title: "titolo", description: "descrizione", is_public: is_public, hidden: hidden)
    p.save
    assert_equal(p[:title], "titolo")
    assert_equal(p.hidden, hidden)
    assert_equal(p.is_public, is_public)
    perms = flickr.photos.getPerms photo_id: p.flickr_id
    assert_equal(p.is_public, perms.ispublic)
    p.destroy
  end

  test 'image_should_have_visibility' do
    image = "http://rubyonrails.org/images/rails.png"
    is_public = 0
    hidden = 2
    p = Image.new(i: image, title: "titolo", description: "descrizione", is_public: is_public, hidden: hidden)
    p.save
    assert_equal(p.hidden, hidden)
    assert_equal(p.is_public, is_public)
    perms = flickr.photos.getPerms photo_id: p.flickr_id
    assert_equal(p.is_public, perms.ispublic)
    p.destroy
  end
  
end
