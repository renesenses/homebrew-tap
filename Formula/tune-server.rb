class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.354"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.354/tune-server-v0.8.354-macos-aarch64.tar.gz"
      sha256 "10a909b2cc1545f5917d6def7ba76d96a473388d26acbb8ed43979aaf9ae6923"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.354/tune-server-v0.8.354-macos-x86_64.tar.gz"
      sha256 "31dedb4863ecf7270e627d235a489e8d5234db5c7ee049312bba2853f2f10cf9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.354/tune-server-v0.8.354-linux-aarch64.tar.gz"
      sha256 "67e53d4b57355c555762f8a62c43ec7e2fa7b53db323e51ec2c3e8a86e28f6ff"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.354/tune-server-v0.8.354-linux-x86_64.tar.gz"
      sha256 "ac41c4d0875f1844383c220d1ce18a744f1d232aa221aae7402ea935e4e94dac"
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
      Tune Server v0.8.354 (Rust) installed!

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
