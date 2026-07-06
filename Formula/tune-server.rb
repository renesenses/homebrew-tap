class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.264"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.264/tune-server-v0.8.264-macos-aarch64.tar.gz"
      sha256 "4cb3a8fe0640ebb3aa26a792d836477341973ac4f57a4e60ebdab8fd116c1aa3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.264/tune-server-v0.8.264-macos-x86_64.tar.gz"
      sha256 "a4033e3820169bcf9461d512e6d12f0246d718588070a3cdbf51ab21aa91fe1e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.264/tune-server-v0.8.264-linux-aarch64.tar.gz"
      sha256 "deadc02280ca49162f309484ad47d7b9934a7d3a3adabf31afc1709d134d3b7b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.264/tune-server-v0.8.264-linux-x86_64.tar.gz"
      sha256 "cdf209abdd1ad4984c9f8d84407ef7c68e3c6a1319586045cfba470d50494a7d"
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
      Tune Server v0.8.264 (Rust) installed!

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
