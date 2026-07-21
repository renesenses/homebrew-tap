class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.356"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.356/tune-server-v0.8.356-macos-aarch64.tar.gz"
      sha256 "203bc2a346f0ebfd3bf5017be3d28bf4e964b05f790cfcfb23148b7c502be678"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.356/tune-server-v0.8.356-macos-x86_64.tar.gz"
      sha256 "f386b0d956dd4b93176e084c30140c8794a8d55408758d529218885b687d83f6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.356/tune-server-v0.8.356-linux-aarch64.tar.gz"
      sha256 "e29201028dd71c16ba6c3a2047a56cecb2379f1cba022c5e3dc334dba022364a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.356/tune-server-v0.8.356-linux-x86_64.tar.gz"
      sha256 "b666cfc8eabeab46b0d271b54cc67c1440b8993517df5a34379e07feeb07f482"
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
      Tune Server v0.8.356 (Rust) installed!

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
