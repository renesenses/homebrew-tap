class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.45"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "bc874c2470434b2f0b1a408ef294dc9967a13df8b0aeae89fa9ce2d92a6a44c7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "ef6c653664dae9f22dcfd3eac66d1978e705011d34d9a557ed3b32261bbdf1ec"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "53fbf34d56a5c64d57855dc94e7cc5a4254d24b2ca446e071456a8b97b31a7fe"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "b6a25b4aa1821b347e427ede52bbd9157c71f8ddd72f1e084ad4b85533c9b46d"
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
      Tune Server v0.8.45 (Rust) installed!

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
