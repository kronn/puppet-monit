require "spec_helper"

describe 'monit::check::process' do
  context 'with no parameters' do
    let(:title) { 'postgres' }

    it 'generates a basic config snippet' do
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

  context 'with parameters' do
    let(:title) { 'background-worker' }
    let(:params) do
      {
        :pidfile      => '/var/run/workerz.pid',
        :start        => '/usr/local/bin/background start',
        :stop         => '/bin/kill -9 2342',
        :start_extras => 'as uid appworker and gid application',
        :stop_extras  => 'and using the sum',  # pure noise words, ignored by monit
        :customlines  => [
          'group workers'
        ]
      }
    end

    it 'includes the parameters in the config' do
      should contain_file('/etc/monit/conf.d/background-worker.monitrc').with({
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0400',
        'notify'  => 'Service[monit]',
        'content' => %r!check process background-worker
  with pidfile "/var/run/workerz.pid"
  start program = "/usr/local/bin/background start" as uid appworker and gid application
  stop program  = "/bin/kill -9 2342" and using the sum
  group workers!m
      })
    end
  end
end
