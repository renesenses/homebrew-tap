class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.371"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.371/tune-server-v0.8.371-macos-aarch64.tar.gz"
      sha256 "bc8bdecbf25901abd5831c77f6e0a6ff563ea3b9a3d496cf1dba16a10b8870ba"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.371/tune-server-v0.8.371-macos-x86_64.tar.gz"
      sha256 "dea05459c39dbc7315d76ed6a6a6c2261cea5b2d03359f1b71d1d10fe42270ba"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.371/tune-server-v0.8.371-linux-aarch64.tar.gz"
      sha256 "dd83fab17a3ddb15cdad2415e64824c201997ddaf8dec9a36107ddc139e47e19"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.371/tune-server-v0.8.371-linux-x86_64.tar.gz"
      sha256 "939fb8a6a4ac67370071de29180a1266e93056a10eada61d4832659ab5e90266"
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
      Tune Server v0.8.371 (Rust) installed!

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
