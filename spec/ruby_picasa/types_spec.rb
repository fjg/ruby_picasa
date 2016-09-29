require File.join(File.dirname(__FILE__), '../spec_helper')

include RubyPicasa

shared_examples_for 'a RubyPicasa document' do
  it 'should have a feed_id' do
    @object.feed_id.should_not be_nil
  end

  it 'should have an author' do
    unless @no_author
      @object.author.should_not be_nil
      @object.author.name.should == 'Liz'
      @object.author.uri.should == 'http://picasaweb.google.com/liz'
    end
  end

  it 'should get links by name' do
    @object.link('abc').should be_nil
    @object.link('self').href.should_not be_nil
  end

  it 'should do nothing for previous and next' do
    @object.previous.should be_nil if @object.link('previous').nil?
    @object.next.should be_nil if @object.link('next').nil?
  end

  it 'should get the feed' do
    @object.session.expects(:get_url).with(@object.feed_id.
                                            gsub(/entry/, 'feed').
                                            gsub(/default/, 'liz'), {})
    @object.feed
  end

  it 'should have links' do
    @object.links.should_not be_empty
    @object.links.each do |l|
      l.should be_an_instance_of(Objectify::Atom::Link)
    end
  end

  describe 'session' do
    it 'should return @session' do
      @object.session = :sess
      @object.session.should == :sess
    end

    it 'should get the parent session' do
      @object.session = nil
      @parent.expects(:session).returns(:parent_sess)
      @object.session.should == :parent_sess
    end

    it 'should be nil if no parent' do
      @object.session = nil
      @object.expects(:parent).returns nil
      @object.session.should be_nil
    end
  end
end

describe User do
  it_should_behave_like 'a RubyPicasa document'

  before(:all) do
    @xml = open_file('user.atom').read
  end

  before(:each) do
    @parent = mock('parent')
    @object = @user = User.new(@xml, @parent)
    @user.session = mock('session')
  end

  it 'should have albums' do
    @user.albums.length.should == 1
    @user.albums.first.should be_an_instance_of(Album)
  end

  it 'should have a user' do
    @user.user.should_not be_empty
  end

  it 'should have a nickname' do
    @user.nickname.should_not be_empty
  end
end

describe RecentPhotos do
  it_should_behave_like 'a RubyPicasa document'

  before :all do
    @xml = open_file('recent.atom').read
  end

  before do
    @parent = mock('parent')
    @object = @album = RecentPhotos.new(@xml, @parent)
    @album.session = mock('session')
  end

  it 'should have 1 photo' do
    @album.photos.length.should == 1
    @album.photos.first.should be_an_instance_of(Photo)
  end

  it 'should request next' do
    @album.session.expects(:get_url).with('http://picasaweb.google.com/data/feed/api/user/liz?start-index=2&max-results=1&kind=photo').returns(:result)
    @album.next.should == :result
  end

  it 'should not request previous on first page' do
    @album.session.expects(:get_url).never
    @album.previous.should be_nil
  end
end

describe Album do
  describe 'with Video' do
    before :all do
      @xml = open_file('album-video.atom').read
    end

    before do
      @parent = mock('parent')
      @object = @album = Album.new(@xml, @parent)
      @album.session = mock('session')
    end

    it 'should have 1 entry' do
      @album.entries.length.should == 2
    end

    it 'should have 0 photos' do
      @album.photos.length.should == 1
    end

    it 'should have 1 videos' do
      @album.videos.length.should == 1
    end

    it 'should have a numeric id' do
      @object.id.should_not be_nil
      @object.id.to_s.should match(/\A\d+\Z/)
    end

    it 'should get links by name' do
      @album.link('abc').should be_nil
      @album.link('alternate').href.should == 'https://picasaweb.google.com/album_alternate_no_auth_key'
    end

    it 'should not be public' do
      @album.public?.should be(false)
    end

    it 'should not be private' do
      @album.private?.should be(false)
    end

    it 'should be protected' do
      @album.protected?.should be(true)
    end

    describe 'first Video' do
      before do
        @video = @album.videos.first
        @video.should be_an_instance_of(Photo)
      end

      it 'should have a parent' do
        @video.parent.should == @album
      end

      it 'should not have an author' do
        @video.author.should be_nil
      end

      it 'should have a content' do
        @video.content.should be_an_instance_of(PhotoUrl)
      end

      it 'should have a content with medium as video' do
        @video.content.medium.should == 'video'
      end

      it 'should have a license' do
        @video.license.should be_an_instance_of(Photo::License)
        @video.license.id.should == 0
        @video.license.name.should == "All Rights Reserved"
      end

      it 'should have 3 thumbnails' do
        @video.thumbnails.length.should == 3
        @video.thumbnails.each do |t|
          t.should be_an_instance_of(ThumbnailUrl)
        end
      end

      it 'should have a numeric id' do
        @video.id.should_not be_nil
        @video.id.to_s.should match(/\A\d+\Z/)
      end

      it 'should have a default url' do
        @video.url.should == 'https://lh3.googleusercontent.com/vXVj5Zd5xjG4F0_WkdcucHQd6rC__ziB12FTJaDMau7IIfjyjvDZT7SUvH_vbD6h516iX61-pw=m18'
      end

      it 'should have thumbnail urls' do
        @video.url('72').should == 'https://lh3.googleusercontent.com/-Qg9di7kDSgQ/VGn1uIbsRiI/AAAAAAAAJ3Y/hqfZkEJ3KMAe-OX8_MTHoMW5upRY7wfTQCHM/s72/IMG_2112.mp4'
      end

      it 'should have a default video url with options true' do
        @video.url(nil, true).should == [
          'https://lh3.googleusercontent.com/vXVj5Zd5xjG4F0_WkdcucHQd6rC__ziB12FTJaDMau7IIfjyjvDZT7SUvH_vbD6h516iX61-pw=m18',
          { :width => 360, :height => 360 }
        ]
      end

      it 'should have a default url with options' do
        @video.url(nil, :id => 'p').should == [
          'https://lh3.googleusercontent.com/vXVj5Zd5xjG4F0_WkdcucHQd6rC__ziB12FTJaDMau7IIfjyjvDZT7SUvH_vbD6h516iX61-pw=m18',
          { :width => 360, :height => 360, :id => 'p' }
        ]
      end

      it 'should have a default url with options first' do
        @video.url(:id => 'p').should == [
          'https://lh3.googleusercontent.com/vXVj5Zd5xjG4F0_WkdcucHQd6rC__ziB12FTJaDMau7IIfjyjvDZT7SUvH_vbD6h516iX61-pw=m18',
          { :width => 360, :height => 360, :id => 'p' }
        ]
      end

      it 'should have thumbnail urls with options' do
        @video.url('72', {:class => 'x'}).should == [
          'https://lh3.googleusercontent.com/-Qg9di7kDSgQ/VGn1uIbsRiI/AAAAAAAAJ3Y/hqfZkEJ3KMAe-OX8_MTHoMW5upRY7wfTQCHM/s72/IMG_2112.mp4',
          { :width => 72, :height => 72, :class => 'x' }
        ]
      end

      it 'should have thumbnail info' do
        @video.thumbnail('72').width.should == 72
      end

      it 'should retrieve valid thumbnail info' do
        video = mock('video')
        thumb = mock('thumb')
        video.expects(:thumbnails).returns([thumb])
        @video.session.expects(:get_url).with('https://picasaweb.google.com/data/feed/api/user/110748374958450232683/albumid/6082662672787567857/photoid/6082662944626984482?authkey=abc',
                                        {:thumbsize => '32c'}).returns(video)
        @video.thumbnail('32c').should == thumb
      end

      it 'should retrieve valid thumbnail info and handle not found' do
        @video.session.expects(:get_url).with('https://picasaweb.google.com/data/feed/api/user/110748374958450232683/albumid/6082662672787567857/photoid/6082662944626984482?authkey=abc',
                                        {:thumbsize => '32c'}).returns(nil)
        @video.thumbnail('32c').should be_nil
      end

      it 'should have a timestamp' do
        @video.timestamp.should_not be_nil
      end

      it 'should have an originalvideo' do
        @video.originalvideo.should be_an_instance_of(RubyPicasa::Photo::OriginalVideo)

        @video.originalvideo.channels.should == 2
        @video.originalvideo.duration.should == 2
        @video.originalvideo.fps.should == 30.0
        @video.originalvideo.height.should == 480
        @video.originalvideo.samplingrate.should == 44.1
        @video.originalvideo.type.should == 'MOV'
        @video.originalvideo.width.should == 480
      end

      xit 'should have audio_codec & video_codec' do
        @video.originalvideo.audio_codec.should == 'AAC'
        @video.originalvideo.video_codec.should == 'H264'
      end

      it 'should have a videostatus' do
        @video.videostatus.should == 'final'
      end

      it 'should have a content[medium]' do
        @video.content.medium == 'video'
      end
    end
  end

  describe 'with Photo' do
    it_should_behave_like 'a RubyPicasa document'

    before :all do
      @xml = open_file('album.atom').read
    end

    before do
      @parent = mock('parent')
      @object = @album = Album.new(@xml, @parent)
      @album.session = mock('session')
    end

    it 'should have a numeric id' do
      @object.id.should_not be_nil
      @object.id.to_s.should match(/\A\d+\Z/)
    end

    it 'should have 1 entry' do
      @album.entries.length.should == 1
    end

    it 'should get links by name' do
      @album.link('abc').should be_nil
      @album.link('alternate').href.should == 'http://picasaweb.google.com/liz/Lolcats'
    end

    it 'should be public' do
      @album.public?.should be(true)
    end

    it 'should not be private' do
      @album.private?.should be(false)
    end


    describe 'photos' do
      it 'should use entries if available' do
        @album.expects(:session).never
        @album.photos.should eq(@album.entries)
      end

      it 'should request photos if needed' do
        @album.entries = []
        photo = mock(video?: false)
        new_album = mock('album', :entries => [photo])
        @album.session.expects(:get_url).with(@album.link(/feed/).href, {}).returns(new_album)
        @album.photos.should == [photo]
      end

      it 'should not request photos twice if there are none' do
        @album.entries = []
        new_album = mock('album', :entries => [])
        @album.session.expects(:get_url).with(@album.link(/feed/).href, {}).times(1).returns(new_album)
        @album.photos.should == []
        # note that mocks are set to accept only one get_url request
        @album.photos.should == []
      end

      it 'should not request photos if there is no session' do
        @album.entries = []
        @album.expects(:session).returns(nil)
        @album.photos.should == []
      end
    end

    describe 'first Photo' do
      before do
        @photo = @album.entries.first
        @photo.should be_an_instance_of(Photo)
      end

      it 'should have a parent' do
        @photo.parent.should == @album
      end

      it 'should not have an author' do
        @photo.author.should be_nil
      end

      it 'should have a content' do
        @photo.content.should be_an_instance_of(PhotoUrl)
      end

      it 'should have a license' do
        @photo.license.should be_an_instance_of(Photo::License)
        @photo.license.id.should == 0
        @photo.license.name.should == "All Rights Reserved"
      end

      it 'should have 3 thumbnails' do
        @photo.thumbnails.length.should == 3
        @photo.thumbnails.each do |t|
          t.should be_an_instance_of(ThumbnailUrl)
        end
      end

      it 'should have a numeric id' do
        @object.id.should_not be_nil
        @object.id.to_s.should match(/\A\d+\Z/)
      end

      it 'should have a default url' do
        @photo.url.should == 'http://lh5.ggpht.com/liz/SKXR5BoXabI/AAAAAAAAAzs/tJQefyM4mFw/invisible_bike.jpg'
      end

      it 'should have thumbnail urls' do
        @photo.url('72').should == 'http://lh5.ggpht.com/liz/SKXR5BoXabI/AAAAAAAAAzs/tJQefyM4mFw/s72/invisible_bike.jpg'
      end

      it 'should have a default url with options true' do
        @photo.url(nil, true).should == [
          'http://lh5.ggpht.com/liz/SKXR5BoXabI/AAAAAAAAAzs/tJQefyM4mFw/invisible_bike.jpg',
          { :width => 410, :height => 295 }
        ]
      end

      it 'should have a default url with options' do
        @photo.url(nil, :id => 'p').should == [
          'http://lh5.ggpht.com/liz/SKXR5BoXabI/AAAAAAAAAzs/tJQefyM4mFw/invisible_bike.jpg',
          { :width => 410, :height => 295, :id => 'p' }
        ]
      end

      it 'should have a default url with options first' do
        @photo.url(:id => 'p').should == [
          'http://lh5.ggpht.com/liz/SKXR5BoXabI/AAAAAAAAAzs/tJQefyM4mFw/invisible_bike.jpg',
          { :width => 410, :height => 295, :id => 'p' }
        ]
      end

      it 'should have thumbnail urls with options' do
        @photo.url('72', {:class => 'x'}).should == [
          'http://lh5.ggpht.com/liz/SKXR5BoXabI/AAAAAAAAAzs/tJQefyM4mFw/s72/invisible_bike.jpg',
          { :width => 72, :height => 52, :class => 'x' }
        ]
      end

      it 'should have thumbnail info' do
        @photo.thumbnail('72').width.should == 72
      end

      it 'should retrieve valid thumbnail info' do
        photo = mock('photo')
        thumb = mock('thumb')
        photo.expects(:thumbnails).returns([thumb])
        @photo.session.expects(:get_url).with('http://picasaweb.google.com/data/feed/api/user/liz/albumid/5228155363249705041/photoid/5234820919508560306',
                                        {:thumbsize => '32c'}).returns(photo)
        @photo.thumbnail('32c').should == thumb
      end

      it 'should retrieve valid thumbnail info and handle not found' do
        @photo.session.expects(:get_url).with('http://picasaweb.google.com/data/feed/api/user/liz/albumid/5228155363249705041/photoid/5234820919508560306',
                                        {:thumbsize => '32c'}).returns(nil)
        @photo.thumbnail('32c').should be_nil
      end

      it 'should have a timestamp' do
        @photo.timestamp.should_not be_nil
      end
    end
  end
end

describe Search do
  it_should_behave_like 'a RubyPicasa document'

  before :all do
    @xml = open_file('search.atom').read
  end

  before(:each) do
    @no_author = true
    @parent = mock('parent')
    @object = @search = Search.new(@xml, @parent)
    @search.session = mock('session')
  end

  it 'should have 1 entry' do
    @search.entries.length.should == 1
    @search.entries.first.should be_an_instance_of(Photo)
  end

  it 'should alias entries to photos' do
    @search.photos.should == @search.entries
  end

  it 'should request next' do
    @search.session.expects(:get_url).with('http://picasaweb.google.com/data/feed/api/all?q=puppy&start-index=3&max-results=1').returns(:result)
    @search.next.should == :result
  end

  it 'should request previous' do
    @search.session.expects(:get_url).with('http://picasaweb.google.com/data/feed/api/all?q=puppy&start-index=1&max-results=1').returns(:result)
    @search.previous.should == :result
  end
end

describe "Class from XML" do
  it 'should parse result without category cointaining photos' do
    @search = @object = Picasa.new(nil).send(:class_from_xml, open_file('search-without-category.xml'))
    @search.should be_an_instance_of(Search)
    @search.entries.size == 1
    @search.entries.first.should be_an_instance_of Photo
  end

  it 'should parse user photo search without photos' do
    @search = @object = Picasa.new(nil).send(:class_from_xml, open_file('user-without-photos.xml'))
    @search.entries.should be_empty
  end
end

describe "Search by bounding box" do
  before :all do
    @xml = open_file('search-geo-1-result.atom').read
  end

  before do
    @no_author = true
    @parent = mock('parent')
    @object = @search = Search.new(@xml, @parent)
    @search.session = mock('session')
  end

  it 'should have 1 entries' do
    @search.entries.length.should == 1
    @search.entries.first.should be_an_instance_of(Photo)
  end

  it 'should have exif info' do
    @search.entries.first.exif_flash.should == true
    @search.entries.first.exif_fstop.should == 2.8
    @search.entries.first.exif_make.should == 'Canon'
    @search.entries.first.unique_id.should == '358e5f03385d40c41dfdf3ad9a80868c'
  end

  it 'should have geo info' do
    @search.entries.first.point.should_not be_nil
    @search.entries.first.point.lat.should be_an_instance_of Float
    @search.entries.first.point.lat.should_not eql(0)
    @search.entries.first.point.lng.should be_an_instance_of Float
    @search.entries.first.point.lng.should_not eql(0)
    @search.entries.first.location.should_not be_empty
  end
end

