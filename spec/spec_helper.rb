require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/ruby_picasa'))

require 'mocha'
require 'pp'

def open_file(name)
  open(File.join(File.dirname(__FILE__), File.join('sample', name)))
end

RSpec.configure do |config|
  config.mock_framework = :mocha
end

class DummyTokenStore
  def initialize
    @tokens = {}
  end

  def load(id)
    @tokens[id]
  end

  def store(id, token)
    @tokens[id] = token
  end

  def delete(id)
    @tokens.delete(id)
  end
end
