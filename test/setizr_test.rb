require 'test/unit'
require 'flickrize/setizr'

class SetizrTest < ActiveSupport::TestCase
  
  test 'respond_to_setizr' do
    assert_respond_to(Photoset, :setizr)
    assert_respond_to(Gallery, :setizr)
  end
  
  # test attr_accessor inside setizr
  test 'set_has_set_id_attrs' do
    p = Photoset.new
    assert_respond_to(p, :set_id)
  end

  # test attr_accessor inside setizr with custom virtual attributes
  test 'gallery_has_photoset_id_attrs' do
    i = Gallery.new
    assert_respond_to(i, :photoset_id)
  end
  
  #test before_create and before_update and before_destroy inside setizr
#  test 'before_create_set_id' do
#    set = Photoset.new(title: "titolo", description: "descrizione", primary_photo_id: 6336163931)
#    assert(set.save, "non ha salvato")
#    assert_not_nil(set.set_id)
#    # update a set
#    set.update_attributes(title: "titolo2", description: "description2")
#    # destroy a set
#    assert(set.destroy, "set non cancellato")
#    assert_raise FlickRaw::FailedResponse do
#      flickr.photosets.getInfo photoset_id: set.set_id
#      "esiste ancora!"
#    end
#    assert_nil(Photoset.find_by_set_id(set.set_id))
#  end

  #test before_create and before_update and before_destroy inside setizr
  test 'before_create_photoset_id' do
    set = Gallery.new(title: "titolo", description: "descrizione", primary_photo_id: 6336163931)
    assert(set.save, "non ha salvato")
    assert_not_nil(set.photoset_id)
    # update a set
    set.update_attributes(title: "titolo2", description: "description2")
    # destroy a set
    assert(set.destroy, "set non cancellato")
    assert_raise FlickRaw::FailedResponse do
      flickr.photosets.getInfo photoset_id: set.photoset_id
      "esiste ancora!"
    end
    assert_nil(Gallery.find_by_photoset_id(set.photoset_id))
  end
end
