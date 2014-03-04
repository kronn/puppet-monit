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

  it 'reloads monit on config changes' do
    should contain_exec('Exec[monit reload]').with({
      'command'     => 'monit reload',
      'path'        => ['/usr/bin', '/usr/sbin'],
      'refreshonly' => true
    })

    should contain_file('/etc/monit/monitrc').
      with_notify('Exec[monit reload]')
  end

  context 'by default' do
    it 'writes logs to syslog' do
      should contain_file('/etc/monit/monitrc').
        with_content(/set logfile syslog facility log_daemon/)
    end

    it 'does not specifiy a mail-hostname' do
      should_not contain_file('/etc/monit/monitrc').
        with_content(/using hostname/)
    end
  end

  context 'sends mails' do
    let(:params) do
      {
        'monit_mailserver' => 'smtp.example.net
      port 25
      username "tom-tester"
      password "password1"'
      }
    end
    let(:facts) do
      { :mailname => 'externalname.example.net' }
    end

    it 'using the right hostname' do
      should contain_file('/etc/monit/monitrc').
        with_content(/using hostname "externalname\.example\.net"/)
    end

    it 'setting the right "From:"' do
      should contain_file('/etc/monit/monitrc').
        with_content(/^set mail-format \{ from: monit@externalname\.example\.net \}$/m)
    end

    it 'to a configurable server' do
      should contain_file('/etc/monit/monitrc').
        with_content(/set mailserver smtp.example.net/).
        with_content(/port 25/).
        with_content(/username "tom-tester"/).
        with_content(/password "password1"/)
    end

    it 'omits empty line before hostname' do
      should contain_file('/etc/monit/monitrc') .
        with_content /password "password1"
      using hostname "externalname.example.net"/
    end
  end

  context 'logs output' do
    let(:params) { { 'monit_log_location' => '/var/log/monit.log' } }

    it 'to a configurable logfile' do
      should contain_file('/etc/monit/monitrc').
        with_content(/set logfile \/var\/log\/monit\.log/)
    end
  end
end
