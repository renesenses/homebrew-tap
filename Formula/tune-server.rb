class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.189"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.189/tune-server-v0.8.189-macos-aarch64.tar.gz"
      sha256 "ce064f6a741d759e1fb0c3b429f2ad34efac5971fe13a32d1340ee7f6ce77548"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.189/tune-server-v0.8.189-macos-x86_64.tar.gz"
      sha256 "407c5471e4ccee9935e73e291f1de4583a31309be037692d844ed22a6137ff71"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.189/tune-server-v0.8.189-linux-aarch64.tar.gz"
      sha256 "NO_ARM_LINUX_BUILD"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.189/tune-server-v0.8.189-linux-x86_64.tar.gz"
      sha256 "af1f7b198df4f99d650640fab7eb28be1569e37774c44b8b4a737c5546e5a2ef"
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
      Tune Server v0.8.189 (Rust) installed!

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
