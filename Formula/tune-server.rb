class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.207"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.207/tune-server-v0.8.207-macos-aarch64.tar.gz"
      sha256 "b671d9832747faeab230cc85add875cc2cda4ec829ac6201c010bd13eb392ad0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.207/tune-server-v0.8.207-macos-x86_64.tar.gz"
      sha256 "ce357764b36dd4fc69c94e5c813ddffdb7760aed0d0f02f531fb6e5ece0aaac0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.207/tune-server-v0.8.207-linux-aarch64.tar.gz"
      sha256 "44caac7430b3c4e9f4efa1319e6b5b56239ca75614191d1370e2497bf0b56692"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.207/tune-server-v0.8.207-linux-x86_64.tar.gz"
      sha256 "1a773674ac7afe7035d0e12b9d471220dda0a3fa01394b4cfd562c4a38476cc7"
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
      Tune Server v0.8.207 (Rust) installed!

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
