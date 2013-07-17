require "spec_helper"

describe 'monit' do
  it 'installs monit' do
    should contain_package('monit').with_ensure('installed')
    should contain_service('monit').with_ensure('running')
  end

  it 'prevents missing directories' do
    should contain_file('/etc/monit').with_ensure('directory')
    should contain_file('/etc/monit/conf.d').with_ensure('directory')
  end

  it 'configures monit' do
    should contain_file('/etc/monit/monitrc').with({
      'ensure'  => 'present',
      'content' => /set daemon/
    })
  end
end
