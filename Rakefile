# -*- ruby -*-
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'bundler/gem_tasks'

require './lib/ruby_picasa.rb'

desc 'Run rake task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--colour', '--format', 'documentation']
end

desc 'Runs the specs'
task all: [:spec]

task default: :all
