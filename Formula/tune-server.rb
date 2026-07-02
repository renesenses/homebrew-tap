class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.235"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.235/tune-server-v0.8.235-macos-aarch64.tar.gz"
      sha256 "0eaaf96251c710dcf688c9bee4eadfbd0953c7ab685c5be27bbb6666cf7b2127"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.235/tune-server-v0.8.235-macos-x86_64.tar.gz"
      sha256 "526f6ebb12fd7667da4583fe18e40e572f460862be1c0700f423a4eb6debfe3c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.235/tune-server-v0.8.235-linux-aarch64.tar.gz"
      sha256 "48070cdbeed90e686ea611f33867f7a61c4ec6d3a4f22cb7e08f48eab97010be"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.235/tune-server-v0.8.235-linux-x86_64.tar.gz"
      sha256 "e09b016ab9573257183acee8969614eaddd2868b67d1fa9dcfd6b17a03b34bb5"
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
      Tune Server v0.8.235 (Rust) installed!

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
