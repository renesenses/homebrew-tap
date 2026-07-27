class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.18"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.18/tune-server-v0.9.18-macos-aarch64.tar.gz"
      sha256 "e3bf2fdd007bb2d624363bae14363253884ec235bdbc733136992c19768358d6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.18/tune-server-v0.9.18-macos-x86_64.tar.gz"
      sha256 "ae02833878c2ac5bf97baf24430dfef850d0f39a993c05723b023d99db4fa8ed"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.18/tune-server-v0.9.18-linux-aarch64.tar.gz"
      sha256 "03c747b74a0bd1bbca9feda79906f3505f72ff1a8a9b3abcd14b112f738a871a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.18/tune-server-v0.9.18-linux-x86_64.tar.gz"
      sha256 "2161c3a468ea0aa2472fade01e64143a4beb9d16a1f74af8a441436e487d2ea4"
    end
  end

  def install
    bin.install "tune-server"
    pkgshare.install "web"

    (bin/"tune-server-launcher").write <<~EOS
      #!/bin/bash
      export PATH="#{Formula["ffmpeg"].opt_bin}:$PATH"
      export TUNE_PORT="${TUNE_PORT:-8888}"
      export TUNE_WEB_DIR="#{pkgshare}/web"
      exec "#{bin}/tune-server" "$@"
    EOS
    chmod 0755, bin/"tune-server-launcher"
  end

  def post_install
    (var/"tune-server").mkpath
    (var/"tune-server/artwork_cache").mkpath

    # Installing over a running server leaves it executing a binary that no
    # longer matches what is on disk. macOS then stops recognising the process
    # and the kernel drops every connection it makes to the local network
    # (`tcp drop outgoing ... reason: NECP`, EHOSTUNREACH) while its internet
    # traffic keeps flowing — so DLNA and AirPlay devices go silent with no
    # obvious cause, and nothing but a restart brings them back.
    return unless OS.mac?

    # No guard on the plist existing: Homebrew points HOME at a scratch
    # directory during install, so probing ~/Library/LaunchAgents here finds
    # nothing even when the service is installed. kickstart -k simply fails when
    # the job is not loaded, and quiet_system keeps that from failing the
    # install.
    quiet_system "/bin/launchctl", "kickstart", "-k",
                 "gui/#{Process.uid}/homebrew.mxcl.tune-server"
  end

  def caveats
    <<~EOS
      Tune Server v0.9.18 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

      If the service was already running, this install restarted it. Should your
      DLNA or AirPlay devices stop responding after an upgrade, macOS has tied
      its local-network permission to the previous binary — run:

        brew services restart tune-server

      Legacy Python version: brew install renesenses/tap/tune-server-python
    EOS
  end

  service do
    run [opt_bin/"tune-server-launcher"]
    working_dir var/"tune-server"
    keep_alive true
    log_path var/"log/tune-server.log"
    error_log_path var/"log/tune-server.log"
    environment_variables PATH: std_service_path_env
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tune-server --version 2>&1", 0)
  end
end
