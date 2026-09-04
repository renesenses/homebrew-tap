class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.135"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.135/tune-server-v0.9.135-macos-aarch64.tar.gz"
      sha256 "35cadea29adaeaa55843e76f6ebc597eabcfe74e2e115c8d0a2f153a950d1658"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.135/tune-server-v0.9.135-macos-x86_64.tar.gz"
      sha256 "937987e97f8c9093673c4d4eb037888c9523e10d7022d3b6218b7240aca8188e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.135/tune-server-v0.9.135-linux-aarch64.tar.gz"
      sha256 "b81c2f9be923e4ed6659c7c8c51654e70f6f758be9c744dd566857e328db6f00"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.135/tune-server-v0.9.135-linux-x86_64.tar.gz"
      sha256 "1eddc25575bc417118f5aad3bcbcfb0ada9bfb184b680dff8539d3504365a653"
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
      Tune Server v0.9.135 (Rust) installed!

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
