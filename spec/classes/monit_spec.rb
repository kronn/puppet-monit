require "spec_helper"

describe "monit" do
  it "installs monit" do
    should contain_package("monit").with_ensure("installed")
    should contain_service("monit").with_ensure("running")
  end

  context "starts the service at boot" do
    context "on Ubuntu 12.04 - precise" do
      let(:facts) do
        {
          :lsbdistcodename => "precise",
        }
      end

      it do
        should contain_file("/etc/default/monit").
          with_ensure("present").
          with_content(/^MONIT_OPTS="-d 120"/).
          with_content(/^START=yes/)
      end
    end

    context "on Ubuntu 14.04 - trusty" do
      let(:facts) do
        {
          :lsbdistcodename => "trusty",
        }
      end

      it do
        should contain_file("/etc/default/monit").
          with_ensure("present").
          with_content(/^MONIT_OPTS=""/).
          with_content(/^START=yes/)
      end
    end

    context "on Debian 6 - squeeze" do
      let(:facts) do
        {
          :lsbdistcodename => "squeeze",
        }
      end

      it do
        should contain_file("/etc/default/monit").
          with_ensure("present").
          with_content(/^CHECK_INTERVALS=120/).
          with_content(/^startup=1/)
      end
    end

    context "on Ubuntu 10.04 - lucid" do
      let(:facts) do
        {
          :lsbdistcodename => "lucid",
        }
      end

      it do
        should contain_file("/etc/default/monit").
          with_ensure("present").
          with_content(/^CHECK_INTERVALS=120/).
          with_content(/^startup=1/)
      end
    end
  end

  it "prevents missing directories" do
    should contain_file("/etc/monit").with_ensure("directory")
    should contain_file("/etc/monit/conf.d").with_ensure("directory")
  end

  it "configures monit" do
    should contain_file("/etc/monit/monitrc").
      with_ensure("present").
      with_content(/set daemon/).
      with_content(/^include /)
  end

  it "reloads monit on config changes" do
    should contain_exec("monit reload").with({
      "command"     => "monit reload",
      "path"        => ["/usr/bin", "/usr/sbin"],
      "refreshonly" => true
    })

    should contain_file("/etc/monit/monitrc").
      with_notify("Exec[monit reload]")
  end

  context "by default" do
    it "writes logs to syslog" do
      should contain_file("/etc/monit/monitrc").
        with_content(/set logfile syslog facility log_daemon/)
    end

    it "does not specifiy a mail-hostname" do
      should_not contain_file("/etc/monit/monitrc").
        with_content(/using hostname/)
    end
  end

  context "sends mails" do
    let(:params) do
      {
        "monit_mailserver" => 'smtp.example.net
      port 25
      username "tom-tester"
      password "password1"'
      }
    end
    let(:facts) do
      { :mailname => "externalname.example.net" }
    end

    it "using the right hostname" do
      should contain_file("/etc/monit/monitrc").
        with_content(/using hostname "externalname\.example\.net"/)
    end

    it 'setting the right "From:"' do
      should contain_file("/etc/monit/monitrc").
        with_content(/^set mail-format \{ from: monit@externalname\.example\.net \}$/m)
    end

    it "to a configurable server" do
      should contain_file("/etc/monit/monitrc").
        with_content(/set mailserver smtp.example.net/).
        with_content(/port 25/).
        with_content(/username "tom-tester"/).
        with_content(/password "password1"/)
    end

    it "omits empty line before hostname" do
      should contain_file("/etc/monit/monitrc") .
        with_content /password "password1"
      using hostname "externalname.example.net"/
    end
  end

  context "logs output" do
    let(:params) { { "monit_log_location" => "/var/log/monit.log" } }

    it "to a configurable logfile" do
      should contain_file("/etc/monit/monitrc").
        with_content(/set logfile \/var\/log\/monit\.log/)
    end
  end
end
