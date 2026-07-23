class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.370"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.370/tune-server-v0.8.370-macos-aarch64.tar.gz"
      sha256 "707287ff94d166697049e820f80beac13ba1d8c6e9b840be6fa7ab1eeac0c106"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.370/tune-server-v0.8.370-macos-x86_64.tar.gz"
      sha256 "5f4cbeeeb574eedcebb015c223e3533ecf160627dd0674178ec3578bf9bcec4c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.370/tune-server-v0.8.370-linux-aarch64.tar.gz"
      sha256 "e11b1dc1e37a0f2b5e71f500e6391cf5477ea05ae02f29cc58e01c8ad1099bb6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.370/tune-server-v0.8.370-linux-x86_64.tar.gz"
      sha256 "66199b2a88c72bde3a50fab23e33cb838a1be6964522b5dd2f9781862fc5a8c5"
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
      Tune Server v0.8.370 (Rust) installed!

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
