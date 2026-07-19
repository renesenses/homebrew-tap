class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.342"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.342/tune-server-v0.8.342-macos-aarch64.tar.gz"
      sha256 "eae5d78e1f0707fe06869fb28192d110e3e2c5404fda72f8ec45c131322a27cc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.342/tune-server-v0.8.342-macos-x86_64.tar.gz"
      sha256 "9d8a6742ba0c2897b62c0186f92713e410fe108f4f2a5ae586a46da1a74e7ec0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.342/tune-server-v0.8.342-linux-aarch64.tar.gz"
      sha256 "4696d99b2e1fd282b39166344df6e73bfbfad93edfdc3cfc48e21adf77cefd28"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.342/tune-server-v0.8.342-linux-x86_64.tar.gz"
      sha256 "d1bf59cbe8bfe8422cd3da6d784b14b238fe055efcf1dbec9300c2ee1fd04342"
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
      Tune Server v0.8.342 (Rust) installed!

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
