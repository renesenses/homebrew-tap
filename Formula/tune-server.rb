class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.200"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.200/tune-server-v0.8.200-macos-aarch64.tar.gz"
      sha256 "44cc59dea64b823667b6ab65f4024b3d8e73b737ef353a92c9456bc6c188d56d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.200/tune-server-v0.8.200-macos-x86_64.tar.gz"
      sha256 "4675499331dca3c746e8dd59d8ac175c1438a1a0d8b2ec1eb0db3d0098b6941c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.200/tune-server-v0.8.200-linux-aarch64.tar.gz"
      sha256 "NO_ARM_LINUX_BUILD"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.200/tune-server-v0.8.200-linux-x86_64.tar.gz"
      sha256 "df36e7b4f21424d1b1ee2360479ca7160ae01c3b5d390fbe66e5355dafc7d1be"
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
      Tune Server v0.8.200 (Rust) installed!

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
