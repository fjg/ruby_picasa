# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-picasa}
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["pangloss", "darrick@innatesoftware.com", "fjg@happycoders.org"]
  s.date = %q{2010-11-11}
  s.description = %q{Provides a super easy to use object layer for authenticating and accessing Picasa through their API.}
  s.email = %q{fjg@happycoders.org}
  s.extra_rdoc_files = [
    "README.txt"
  ]
  s.files = [
    ".autotest",
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
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/fjg/ruby_picasa}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Provides a super easy to use object layer for authenticating and accessing Picasa through their API.}
  s.test_files = [
    "spec/ruby_picasa/types_spec.rb",
     "spec/ruby_picasa_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<objectify-xml>, [">= 0.2.3"])
    else
      s.add_dependency(%q<objectify-xml>, [">= 0.2.3"])
    end
  else
    s.add_dependency(%q<objectify-xml>, [">= 0.2.3"])
  end
end
