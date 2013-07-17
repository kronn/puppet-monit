require "spec_helper"

describe 'monit::check::process' do
  let(:title) { 'postgres' }

  it 'generates a config snippet' do
    should contain_file('/etc/monit/conf.d/postgres.monitrc').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0400',
      'notify'  => 'Service[monit]',
      'content' => /check process postgres/
    })
  end
end
