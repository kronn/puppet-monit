require 'rspec-puppet'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')

  c.default_facts = {
    :concat_basedir         => '/var/lib/puppet/concat',
    :kernel                 => 'Linux',
    :operatingsystem        => 'Ubuntu',
    :operatingsystemrelease => '12.04',
    :osfamily               => 'Debian',
    :lsbdistcodename        => 'precise',
  }
end
