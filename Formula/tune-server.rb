class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.353"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.353/tune-server-v0.8.353-macos-aarch64.tar.gz"
      sha256 "8d0cec433c608653c4c3086fdb525ee6baeff1cd1c6a93d031c81dc30403377d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.353/tune-server-v0.8.353-macos-x86_64.tar.gz"
      sha256 "4136ced124f98097a7b5f4341b1edccda51be15ba0e600ca7466b29492c12684"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.353/tune-server-v0.8.353-linux-aarch64.tar.gz"
      sha256 "f2fd88efe0e35e2c0c93e79900f089c81614acbda2f8b4541e859de9756c6871"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.353/tune-server-v0.8.353-linux-x86_64.tar.gz"
      sha256 "80bd49b14e42dd0b99fad8ef10900f7e4f95fd258530dc155c76a93d6c9281ab"
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
      Tune Server v0.8.353 (Rust) installed!

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
