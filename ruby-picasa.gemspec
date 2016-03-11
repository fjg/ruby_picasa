# -*- ruby -*-
# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'ruby_picasa/version'

Gem::Specification.new do |s|
  s.name = 'ruby-picasa'
  s.version = RubyPicasa::VERSION
  s.authors = ['pangloss',
               'darrick@innatesoftware.com',
               'fourcade.m+ruby_picasa@gmail.com']
  s.email = 'fourcade.m+ruby_picasa@gmail.com'
  s.homepage = 'http://github.com/fjg/ruby_picasa'
  s.summary = 'Accessing Picasa through their API.'
  s.description = <<-eos
    Provides a super easy to use object layer for authenticating
    and accessing Picasa through their API.
  eos

  s.files = [
     ".gitignore",
     "History.txt",
     "Manifest.txt",
     "README.txt",
     "Rakefile",
     "VERSION",
     "init.rb",
     "lib/ruby_picasa.rb",
     "lib/ruby_picasa/types.rb",
     "ruby-picasa.gemspec",
     "spec/ruby_picasa/types_spec.rb",
     "spec/ruby_picasa_spec.rb",
     "spec/sample/album.atom",
     "spec/sample/recent.atom",
     "spec/sample/search-geo-1-result.atom",
     "spec/sample/search-without-category.xml",
     "spec/sample/search.atom",
     "spec/sample/user-without-photos.xml",
     "spec/sample/user.atom",
     "spec/spec_helper.rb"
  ]
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']
  s.platform      = Gem::Platform::RUBY

  s.extra_rdoc_files = ['README.txt']
  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency 'activesupport', '>= 3.2'
  s.add_dependency 'googleauth', '>= 0.5.1'
  s.add_dependency 'objectify-xml', '>= 0.2.3'
end
