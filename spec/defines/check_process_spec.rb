require "spec_helper"

describe "monit::check::process" do
  context "with no parameters" do
    let(:title) { "postgres" }

    it "generates a basic config snippet" do
      should contain_file("/etc/monit/conf.d/postgres.monitrc").with({
        "ensure"  => "present",
        "owner"   => "root",
        "group"   => "root",
        "mode"    => "0400",
        "notify"  => "Service[monit]",
      }).
      with_content(/check process postgres/).
      without_content(/depends on/)
    end
  end

  context "with parameters and pidfile" do
    let(:title) { "background-worker" }
    let(:params) do
      {
        :pidfile      => "/var/run/workerz.pid",
        :start        => "/usr/local/bin/background start",
        :stop         => "/bin/kill -9 2342",
        :start_extras => "as uid appworker and gid application",
        :stop_extras  => "and using the sum",  # pure noise words, ignored by monit
        :depends      => "systemd-database",
        :customlines  => [
          "group workers"
        ]
      }
    end

    it "includes the parameters in the config" do
      should contain_file("/etc/monit/conf.d/background-worker.monitrc").with({
        "ensure"  => "present",
        "owner"   => "root",
        "group"   => "root",
        "mode"    => "0400",
        "notify"  => "Service[monit]",
        "content" => %r!check process background-worker
  with pidfile "/var/run/workerz.pid"
  start program = "/usr/local/bin/background start" as uid appworker and gid application
  stop program  = "/bin/kill -9 2342" and using the sum
  depends on systemd-database
  group workers!m
      })
    end
  end

  context "with parameters and matching" do
    let(:title) { "irc-bot" }
    let(:params) do
      {
        :matching     => "hubot -a irc -n botsy",
        :start        => "/usr/local/bin/hubot -a irc -n botsy",
        :stop         => "/bin/kill -9 2342",
        :start_extras => "and"
      }
    end

    it "includes the parameters in the config" do
      should contain_file("/etc/monit/conf.d/irc-bot.monitrc").with({
        "ensure"  => "present",
        "owner"   => "root",
        "group"   => "root",
        "mode"    => "0400",
        "notify"  => "Service[monit]",
        "content" => %r!check process irc-bot
  matching "hubot -a irc -n botsy"
  start program = "/usr/local/bin/hubot -a irc -n botsy" and
  stop program  = "/bin/kill -9 2342" !m,
      })
    end
  end
end
