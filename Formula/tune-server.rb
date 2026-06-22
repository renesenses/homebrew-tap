class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.150"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.150/tune-server-v0.8.150-macos-aarch64.tar.gz"
      sha256 "d9569e88e080fba8bf6fa00aaa1169eb8e5c934014450dfdd58fdbb28ee3c0f7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.150/tune-server-v0.8.150-macos-x86_64.tar.gz"
      sha256 "a740af42b20c4fec5a89232f1bb09c03efb0060c0f4dbf72b62b59a6a471db58"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.150/tune-server-v0.8.150-linux-aarch64.tar.gz"
      sha256 "f11c394d5e1da6a4ad1f5b29700c4ce5296157b5281703ef1d3dbceb4e807679"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.150/tune-server-v0.8.150-linux-x86_64.tar.gz"
      sha256 "4ab1295c88eeb6a761fae8015aae0554ca2f35dd9980a335296a0885d5b46a10"
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
      Tune Server v0.8.150 (Rust) installed!

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
