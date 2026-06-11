class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.85"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.85/tune-server-v0.8.85-macos-aarch64.tar.gz"
      sha256 "f8a3657a58c8d06e78fc539e8408ebd23fb024fcede11b4ac2344be73b3da103"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.85/tune-server-v0.8.85-macos-x86_64.tar.gz"
      sha256 "a8379bb523de67bf84f88335c530b65639729a7cad6e179c234af019ce2ed1b1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.85/tune-server-v0.8.85-linux-aarch64.tar.gz"
      sha256 "35fc748a7e4cd369074e79a640fe24a2cd9af2f2874afc16df6a835aa87379ed"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.85/tune-server-v0.8.85-linux-x86_64.tar.gz"
      sha256 "f1d40480389cf4e68c8048debecda9d05c1e81d6ae6c6b653e2e1be32f417e6e"
    end
  end

  depends_on "ffmpeg"

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
      Tune Server v0.8.85 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

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
