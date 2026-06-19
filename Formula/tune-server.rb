class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.143"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.143/tune-server-v0.8.143-macos-aarch64.tar.gz"
      sha256 "407625ae44c490202bc955fec26f1d3ea1fe7c8824f5256b9bf5aa9bbabeee99"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.143/tune-server-v0.8.143-macos-x86_64.tar.gz"
      sha256 "563372ea77388954bb87d437d725294ef41047158c14bda5022fd61f4ed3816f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.143/tune-server-v0.8.143-linux-aarch64.tar.gz"
      sha256 "17acb0161839eab0e4384b7ed98ad0ec5e79c82e384e9585d7a69d8c4fc3c3bf"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.143/tune-server-v0.8.143-linux-x86_64.tar.gz"
      sha256 "2c3e08fdf815976c9a7db92d0b841b23d420f36cd28944744a9d23704ef7ece8"
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
      Tune Server v0.8.143 (Rust) installed!

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
