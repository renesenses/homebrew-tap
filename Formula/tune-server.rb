class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.120"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.120/tune-server-v0.9.120-macos-aarch64.tar.gz"
      sha256 "9610c24d261497c71f3ee85741db5879bcd9ef935db58ba5da6806219020daf3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.120/tune-server-v0.9.120-macos-x86_64.tar.gz"
      sha256 "ca644237c40e2e5925912a485e72ec205d91fd519f542ecda0c9e23939c379ff"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.120/tune-server-v0.9.120-linux-aarch64.tar.gz"
      sha256 "238ed70eeadd6e06bbf75787918bdd14724e4e71504ce0df35b0ac5a3058db9c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.120/tune-server-v0.9.120-linux-x86_64.tar.gz"
      sha256 "db6cd10265082968aa888fbc8f0bd42752421cfc53ec8aa06ef59efc739082e0"
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
  end

  def caveats
    <<~EOS
      Tune Server v0.9.120 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

      Après une mise à jour, redémarrez le serveur :
      brew services restart tune-server (ou relancez tune-server-launcher).

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
