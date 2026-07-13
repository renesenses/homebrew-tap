class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.303"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.303/tune-server-v0.8.303-macos-aarch64.tar.gz"
      sha256 "617c28fcd159e03d762da7dfa610bf7d58ea9188c9645b336cbcf72912be473d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.303/tune-server-v0.8.303-macos-x86_64.tar.gz"
      sha256 "7300613bb7f7fa8df36d950f18c4fb59a9811e1570366d818087b128172f067c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.303/tune-server-v0.8.303-linux-aarch64.tar.gz"
      sha256 "1fb5e73bd14e48b6e63a42d58ee7c7cca89fea4f6309dcaf1e30ab3023032505"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.303/tune-server-v0.8.303-linux-x86_64.tar.gz"
      sha256 "1332a9a82ff051dd15a54f6ead45edec561a832832ac89459f970dcdf677015f"
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
      Tune Server v0.8.303 (Rust) installed!

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
