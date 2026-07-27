class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.17"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.17/tune-server-v0.9.17-macos-aarch64.tar.gz"
      sha256 "df29194b2edb646f5b8b4ba9c2e1dcdba90c7a5bb4b71c6d6ec3587e13fd3c67"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.17/tune-server-v0.9.17-macos-x86_64.tar.gz"
      sha256 "26586bee63e32803878d6fb4518264bd59287c5e3a8cb7fb921c7ad45457d0aa"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.17/tune-server-v0.9.17-linux-aarch64.tar.gz"
      sha256 "3df28ae30b6de11749cea423c40db75237fc515b5e0642d6dc6598907cd3bb53"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.17/tune-server-v0.9.17-linux-x86_64.tar.gz"
      sha256 "0211eec9b51b6d8ad69c44d08879253127027e56338e982fca2743492626686c"
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
      Tune Server v0.9.17 (Rust) installed!

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
