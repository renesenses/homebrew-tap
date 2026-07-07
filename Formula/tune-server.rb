class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.280"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.280/tune-server-v0.8.280-macos-aarch64.tar.gz"
      sha256 "c1ab8f3864691b0189edde21311cbc522678e59b0808c255df37377d22c6ea87"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.280/tune-server-v0.8.280-macos-x86_64.tar.gz"
      sha256 "9ac1b8988047cccf7b2ff05db087ab559e96f2e9f22934d056ba65f7520188dd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.280/tune-server-v0.8.280-linux-aarch64.tar.gz"
      sha256 "0cb4d1509f7d2d9796054bad043d04078f1be9aaa441f749b15faa342eb3ea1d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.280/tune-server-v0.8.280-linux-x86_64.tar.gz"
      sha256 "b93519358b25bdaab950f8070e25d556816e932ba50832cd8aaf5d17893dbf8f"
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
      Tune Server v0.8.280 (Rust) installed!

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
