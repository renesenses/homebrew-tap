class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.336"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.336/tune-server-v0.8.336-macos-aarch64.tar.gz"
      sha256 "0d5f873e62f4d91a4e80986c562d9d8e48a9d3b4e2e0bd87985030c10243eb08"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.336/tune-server-v0.8.336-macos-x86_64.tar.gz"
      sha256 "671d24f0ee9dac365dca896acefc9d3b6b8825e1e8246f2694521beb4e7cb7b5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.336/tune-server-v0.8.336-linux-aarch64.tar.gz"
      sha256 "0775186a12489664ac9fdc77ed8cd0ed8a2e460f3483eae310621ba725b66dd2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.336/tune-server-v0.8.336-linux-x86_64.tar.gz"
      sha256 "0f808644284d22a697742d1bae37b40da8f3ecce61eb9674900b636fd220b065"
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
      Tune Server v0.8.336 (Rust) installed!

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
