class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.339"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.339/tune-server-v0.8.339-macos-aarch64.tar.gz"
      sha256 "88535a148c7111386475f472d1ba430ccc0a1077d83e43b20d1facb1713c9af0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.339/tune-server-v0.8.339-macos-x86_64.tar.gz"
      sha256 "bf392a963023d34d51c6ad1cd061751d7124695f2e1e3fb6615fe5142d9b5ad6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.339/tune-server-v0.8.339-linux-aarch64.tar.gz"
      sha256 "8d92ebb81d1cf83fcb1129316c09ba2c7936283077f374cdd5ce9b69066aa04b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.339/tune-server-v0.8.339-linux-x86_64.tar.gz"
      sha256 "935ab5dd2ccc8c523f004e6d6d1dbdedf1e7a77a63d12ff53648558c848126f9"
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
      Tune Server v0.8.339 (Rust) installed!

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
