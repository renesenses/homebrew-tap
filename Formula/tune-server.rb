class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.314"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.314/tune-server-v0.8.314-macos-aarch64.tar.gz"
      sha256 "304ca313e89643b25ab87b7e8b2b98841f3aed9ea6d4f8961167b350463ad9ba"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.314/tune-server-v0.8.314-macos-x86_64.tar.gz"
      sha256 "59be9fa8e841e7140b47a5c4c55543b73d7ab37ce72a0bfa3b7ddec5169c65ea"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.314/tune-server-v0.8.314-linux-aarch64.tar.gz"
      sha256 "66c520bbd08887fc1aacb6d17b587a1832d5c38d95a8acf7486ed035eead953d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.314/tune-server-v0.8.314-linux-x86_64.tar.gz"
      sha256 "2f427d746a9d06e055a6e0827dd071184870a938937e0fae087aaf97c39ee5de"
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
      Tune Server v0.8.314 (Rust) installed!

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
