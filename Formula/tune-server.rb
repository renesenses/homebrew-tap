class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.180"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.180/tune-server-v0.8.180-macos-aarch64.tar.gz"
      sha256 "eee3412f2b74c5f51c5648dc972ad7bc8915b824a82904a65e38aa81d9008b26"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.180/tune-server-v0.8.180-macos-x86_64.tar.gz"
      sha256 "24544e2ffb82b2f066d12ce12afd7a362f69796df4b14435325c6ebac6bbfc20"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.180/tune-server-v0.8.180-linux-aarch64.tar.gz"
      sha256 "78c414b879e73f93a5dac97a98ae96b282417adbd6aa16a38a8f568b3f667576"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.180/tune-server-v0.8.180-linux-x86_64.tar.gz"
      sha256 "334733ecbf6182fa6b864845d4883150c0c2e2c50d658b5c41bbae570a35647a"
    end
  end

  def install
    bin.install "tune-server"
    pkgshare.install "web"

    (bin/"tune-server-launcher").write <<~'BASH'
      #!/bin/bash
      export TUNE_PORT="${TUNE_PORT:-8888}"
      SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
      PREFIX="$(dirname "$SELF_DIR")"
      export TUNE_WEB_DIR="${PREFIX}/share/tune-server/web"
      exec "${SELF_DIR}/tune-server" "$@"
    BASH
    chmod 0755, bin/"tune-server-launcher"
  end

  def post_install
    (var/"tune-server").mkpath
    (var/"tune-server/artwork_cache").mkpath
  end

  def caveats
    <<~EOS
      Tune Server v0.8.180 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server
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
