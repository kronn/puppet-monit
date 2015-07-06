#!/usr/bin/env ruby
# vim:fileencoding=utf-8

require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end

if ENV['CI_GENERATE_REPORTS'] == 'true'
  require 'ci/reporter/rake/rspec'

  task :setup_ci_reporter do
    setup_spec_opts("--format", "documentation")
  end

  task :spec => :setup_ci_reporter
end

if ENV['CI_CLEANUP_REPORTS'] == 'true'
  require 'ci/reporter/rake/rspec'
  task :spec => 'ci:setup:spec_report_cleanup'
end

task :lint_config do
  PuppetLint.configuration.fail_on_warnings = true
  PuppetLint.configuration.disable_autoloader_layout
end

task :lint => :lint_config

task :default => [:spec, :lint]
