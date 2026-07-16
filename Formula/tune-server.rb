class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.325"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.325/tune-server-v0.8.325-macos-aarch64.tar.gz"
      sha256 "248068f7fbc1831a712720be8c8e5d5ebb8727bc2b242e9d1ed04eee68e42bde"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.325/tune-server-v0.8.325-macos-x86_64.tar.gz"
      sha256 "d97cb8b1a4026b7a7b7bb0807f9aa951020c289a1e7c1b97e1d90c8b26c46ba5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.325/tune-server-v0.8.325-linux-aarch64.tar.gz"
      sha256 "630d89dd0357ec2018dc14380828a950c2541154444f8628e127d4be66f57d58"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.325/tune-server-v0.8.325-linux-x86_64.tar.gz"
      sha256 "343ace11e7672d1a3ca47aae734b216984c145c1aaf008dcf4ade6f198e93778"
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
      Tune Server v0.8.325 (Rust) installed!

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
