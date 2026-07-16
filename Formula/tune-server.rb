class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.321"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.321/tune-server-v0.8.321-macos-aarch64.tar.gz"
      sha256 "82aeb338346c3819dc57c143ec2717b6552839e8857c41f0282400b2a408f9b6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.321/tune-server-v0.8.321-macos-x86_64.tar.gz"
      sha256 "6a0d583024498a443cc4388276cf9bfe335a6fa2b4956cf3fd36035b0ea801b7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.321/tune-server-v0.8.321-linux-aarch64.tar.gz"
      sha256 "ee1ee68c9dd508380286b591bb408e670120ac253811bf27b25c4a876afcbb36"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.321/tune-server-v0.8.321-linux-x86_64.tar.gz"
      sha256 "f92db1f0262a956fa298bf1b6b889549ad0f6680f3185964b9f244607db1eb4a"
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
      Tune Server v0.8.321 (Rust) installed!

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
