class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.290"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.290/tune-server-v0.8.290-macos-aarch64.tar.gz"
      sha256 "c09f3d42ba758f13db9fd61fc5246b5bc9e3dcdcd0e20a19e0758b6b0a900cf1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.290/tune-server-v0.8.290-macos-x86_64.tar.gz"
      sha256 "33872f8d2008baa17eeddeab2e6e2a6ab73da78132599474ec75a1a97555e1c4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.290/tune-server-v0.8.290-linux-aarch64.tar.gz"
      sha256 "75e8bd7c5e9dde749222e4383ec065b5ef7a4fb713858ad14543b670a7c4c893"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.290/tune-server-v0.8.290-linux-x86_64.tar.gz"
      sha256 "fbb703ddd9de18be14668bd2b77441c665ac960978add455877a8754e2dab148"
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
      Tune Server v0.8.290 (Rust) installed!

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
