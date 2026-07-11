class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.297"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.297/tune-server-v0.8.297-macos-aarch64.tar.gz"
      sha256 "d7720040f6fc2043c3f3237923e77d3c88cff89e8bf7a65eba4d6165c68226d9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.297/tune-server-v0.8.297-macos-x86_64.tar.gz"
      sha256 "29f2a81f005c3a05ebc87ff9c484368adb12a009c2037032989d86b955b8be0c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.297/tune-server-v0.8.297-linux-aarch64.tar.gz"
      sha256 "ba8f4b7ed23c2130dc8fb86e3d105dd8693bb35ba4e611de90483c9248878874"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.297/tune-server-v0.8.297-linux-x86_64.tar.gz"
      sha256 "295a0a82f8c52e654d9f87cefc674c26472071fe0dc40ffc85a19f0606e7c793"
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
      Tune Server v0.8.297 (Rust) installed!

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
