#!/usr/bin/env ruby
# vim:fileencoding=utf-8

require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end

task :lint_config do
  PuppetLint.configuration.fail_on_warnings = true
  PuppetLint.configuration.disable_autoloader_layout
end

task :lint => :lint_config

task :default => [:spec, :lint]
