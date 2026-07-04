class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.255"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.255/tune-server-v0.8.255-macos-aarch64.tar.gz"
      sha256 "b3a08bdcfc546a67feecbe00e5ab8763698d6560a1e45cc27d795d4a115b5b5d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.255/tune-server-v0.8.255-macos-x86_64.tar.gz"
      sha256 "f01c79c382f952dab523323c27491abdeee8fd998ad3d3ce27f650533d8b8eff"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.255/tune-server-v0.8.255-linux-aarch64.tar.gz"
      sha256 "a34554d026c0fe3e074b7ac8a165f7811a169c8d701fbd87798dede419986f24"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.255/tune-server-v0.8.255-linux-x86_64.tar.gz"
      sha256 "d300b6914cbf2612488d53aa70b092193b2e71f30b2dbb9077b0d3887def1e6c"
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
      Tune Server v0.8.255 (Rust) installed!

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
