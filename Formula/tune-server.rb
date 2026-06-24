class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.161"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.161/tune-server-v0.8.161-macos-aarch64.tar.gz"
      sha256 "241eaf7f65d930933506c6a988323e5d68a04394162416db4fba6aecc4214c9a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.161/tune-server-v0.8.161-macos-x86_64.tar.gz"
      sha256 "5e4f6db00107331027ebfb32e8d61ad1faf3360b0c48b835b9282c393c6f365f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.161/tune-server-v0.8.161-linux-aarch64.tar.gz"
      sha256 "1e32a14d10400119b8e68bf5e05ecca50efb04c21e74131eaa2227481da21169"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.161/tune-server-v0.8.161-linux-x86_64.tar.gz"
      sha256 "60e028fc7b608394270e71ba1c079be542fcca13b0d7913f6aa7eb229b82ba61"
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
      Tune Server v0.8.161 (Rust) installed!

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
