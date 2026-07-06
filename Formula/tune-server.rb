class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.270"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.270/tune-server-v0.8.270-macos-aarch64.tar.gz"
      sha256 "d7343d29b20ea1e76595ee1ce03c7511ec93d67a02e121578c7ae905be0faa64"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.270/tune-server-v0.8.270-macos-x86_64.tar.gz"
      sha256 "0752cc625bc6545ad5790d819411b0d6b20d1f4fcadf93d0b572bcd008c5e42e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.270/tune-server-v0.8.270-linux-aarch64.tar.gz"
      sha256 "31e7c380a95c32ad91951924fa1f94e4122f35c3b663e1b316c6fd1e75dc860f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.270/tune-server-v0.8.270-linux-x86_64.tar.gz"
      sha256 "c4880f547e89952e3c822c331f16d2e015f49f97575d0a914e85ad6a6d4c4cb2"
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
      Tune Server v0.8.270 (Rust) installed!

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
