class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.234"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.234/tune-server-v0.8.234-macos-aarch64.tar.gz"
      sha256 "17ac489dcdfb9a0858ecd1e07906d7fa1133c08720f0baa9f2924b78d607e55d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.234/tune-server-v0.8.234-macos-x86_64.tar.gz"
      sha256 "3f25d78a7d33e94457cf3b447b304af9952a7d76c27bd5479f302049cac8df3f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.234/tune-server-v0.8.234-linux-aarch64.tar.gz"
      sha256 "f34e14b4279d99950aa200477616ee11dfcd283364d26ea002367e13d0cfb54b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.234/tune-server-v0.8.234-linux-x86_64.tar.gz"
      sha256 "c217efc9baed2371224af26de4e1aa5bc49f0b2104cb34de49f48bfd81c9fb15"
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
      Tune Server v0.8.234 (Rust) installed!

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
