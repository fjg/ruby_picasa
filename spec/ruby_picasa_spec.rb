require File.join(File.dirname(__FILE__), 'spec_helper')

class Picasa
  class << self
    public :parse_url
  end
  public :auth_header, :with_cache, :class_from_xml
end

describe 'Picasa class methods' do
  it 'should generate an authorization_url' do
    return_url = 'http://example.com/example?example=ex'
    url = Picasa.authorization_url(return_url)
    url.should include(CGI.escape(return_url))
    url.should match(/session=1/)
  end

  it 'should pluck the token from the request' do
    request = mock('request', :params => { 'token' => 'abc' })
    Picasa.token_from_request(request).should == 'abc'
  end

  it 'should authorize a request' do
    Picasa.expects(:token_from_request).with(:request).returns('abc')
    picasa = mock('picasa')
    Picasa.expects(:new).with('abc').returns(picasa)
    picasa.expects(:authorize_token!).with()
    Picasa.authorize_request(:request).should == picasa
  end

  it 'should recognize absolute urls' do
    Picasa.is_url?('http://something.com').should be_true
    Picasa.is_url?('https://something.com').should be_true
    Picasa.is_url?('12323412341').should_not be_true
  end

  it 'should recognize relative urls?' do
    pending 'not currently needed'
    Picasa.is_url?('something.com/else').should be_true
    Picasa.is_url?('/else').should be_true
  end

  describe 'path' do
    it 'should use parse_url and add options' do
      Picasa.expects(:parse_url).with({}).returns(['url', {'a' => 'b'}])
      Picasa.path({}).should ==
        "url?a=b"
    end
    it 'should build the url from user_id and album_id and add options' do
      hash = { :user_id => '123', :album_id => '321' }
      Picasa.expects(:parse_url).with(hash).returns([nil, {}])
      Picasa.path(hash).should ==
        "/data/feed/api/user/123/albumid/321?kind=photo"
    end
    it 'should build the url from special user_id all' do
      hash = { :user_id => 'all' }
      Picasa.expects(:parse_url).with(hash).returns([nil, {}])
      Picasa.path(hash).should ==
        "/data/feed/api/all"
    end
    [ :max_results, :start_index, :tag, :q, :kind,
      :access, :thumbsize, :imgmax, :bbox, :l].each do |arg|
      it "should add #{ arg } to options" do
        Picasa.path(:url => 'url', arg => '!value').should ==
          "url?#{ arg.to_s.dasherize }=%21value"
      end
    end
  end

  describe 'parse_url' do
    it 'should prefer url' do
      hash = { :url => 'url', :user_id => 'user_id', :album_id => 'album_id' }
      Picasa.parse_url(hash).should == ['url', {}]
    end
    it 'should next prefer user_id' do
      Picasa.stubs(:is_url?).returns true
      hash = { :user_id => 'user_id', :album_id => 'album_id' }
      Picasa.parse_url(hash).should == ['user_id', {}]
    end
    it 'should use album_id' do
      Picasa.stubs(:is_url?).returns true
      hash = { :album_id => 'album_id' }
      Picasa.parse_url(hash).should == ['album_id', {}]
    end
    it 'should split up the params' do
      hash = { :url => 'url?specs=fun%21' }
      Picasa.parse_url(hash).should == ['url', { 'specs' => 'fun!' }]
    end
    it 'should not use non-url user_id or album_id' do
      hash = { :user_id => 'user_id', :album_id => 'album_id' }
      Picasa.parse_url(hash).should == [nil, {}]
    end
    it 'should handle with no relevant options' do
      hash = { :saoetu => 'aeu' }
      Picasa.parse_url(hash).should == [nil, {}]
    end
  end
end

describe Picasa do
  def body(text)
    #open_file('user_feed.atom').read
    @response.stubs(:body).returns(text)
  end

  before do
    @response = mock('response')
    @response.stubs(:code).returns '200'
    @http = mock('http')
    @http.stubs(:get).returns @response
    Net::HTTP.stubs(:new).returns(@http)
    @p = Picasa.new 'token'
  end

  it 'should initialize' do
    @p.token.should == 'token'
  end

  describe 'authorize_token!' do
    before do
      @p.expects(:auth_header).returns('Authorization' => 'etc')
      @http.expects(:use_ssl=).with true
      @http.expects(:get).with('/accounts/accounts/AuthSubSessionToken', 
        'Authorization' => 'etc').returns(@response)
    end

    it 'should set the new token' do
      body 'Token=hello'
      @p.authorize_token!
      @p.token.should == 'hello'
    end

    it 'should raise if the token is not found' do
      body 'nothing to see here'
      lambda do
        @p.authorize_token!
      end.should raise_error(RubyPicasa::PicasaTokenError)
      @p.token.should == 'token'
    end
  end

  it 'should get the user' do
    @p.expects(:get).with(:user_id => 'default')
    @p.user
  end

  it 'should get an album' do
    @p.expects(:get).with(:album_id => 'album')
    @p.album('album')
  end
  
  it 'should get a url' do
    @p.expects(:get).with(:url => 'the url')
    @p.get_url('the url')
  end

  describe 'search' do
    it 'should prefer given options' do
      @p.expects(:get).with(:q => 'q', :max_results => 20, :user_id => 'me', :kind => 'comments')
      @p.search('q', :max_results => 20, :user_id => 'me', :kind => 'comments', :q => 'wrong')
    end
    it 'should have good defaults' do
      @p.expects(:get).with(:q => 'q', :max_results => 10, :user_id => 'all', :kind => 'photo')
      @p.search('q')
    end
  end

  it 'should get recent photos' do
    @p.expects(:get).with(:user_id => 'default', :recent_photos => true)
    @p.recent_photos
  end

  describe 'album_by_title' do
    before do
      @a1 = mock('a1')
      @a2 = mock('a2')
      @a1.stubs(:title).returns('a1')
      @a2.stubs(:title).returns('a2')
      albums = [ @a1, @a2 ]
      user = mock('user', :albums => albums)
      @p.expects(:user).returns(user)
    end

    it 'should match the title string' do
      @a2.expects(:load).with({}).returns :result
      @p.album_by_title('a2').should == :result
    end

    it 'should match a regex' do
      @a1.expects(:load).with({}).returns :result
      @p.album_by_title(/a\d/).should == :result
    end

    it 'should return nil' do
      @p.album_by_title('aoeu').should be_nil
    end
  end

  describe 'xml' do
    it 'should return the body with a 200 status' do
      body 'xml goes here'
      @p.xml.should == 'xml goes here'
    end
    it 'should return nil with a non-200 status' do
      body 'xml goes here'
      @response.expects(:code).returns '404'
      @p.xml.should be_nil
    end
  end

  describe 'get' do
    it 'should call class_from_xml if with_cache yields' do
      @p.expects(:with_cache).with({}).yields(:xml).returns(:result)
      @p.expects(:class_from_xml).with(:xml)
      @p.get.should == :result
    end

    it 'should do nothing if with_cache does not yield' do
      @p.expects(:with_cache).with({}) # doesn't yield
      @p.expects(:class_from_xml).never
      @p.get.should be_nil
    end
  end

  describe 'auth_header' do
    it 'should build an AuthSub header' do
      @p.auth_header.should == { "Authorization" => %{AuthSub token="token"} }
    end

    it 'should do nothing' do
      p = Picasa.new nil
      p.auth_header.should == { }
    end
  end
end