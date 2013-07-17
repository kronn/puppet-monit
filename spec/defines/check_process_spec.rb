require "spec_helper"

describe 'monit::check::process' do
  let(:title) { 'postgresql' }

  it do
    should contain_file('/etc/monit/conf.d/postgresql.monitrc').with({
      'ensure'   => 'present',
      'owner'    => 'root',
      'group'    => 'root',
      'mode'     => '0400'
    })
  end
end
