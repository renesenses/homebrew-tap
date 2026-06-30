class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.212"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.212/tune-server-v0.8.212-macos-aarch64.tar.gz"
      sha256 "3e82503d4c5e7e9aeaee91c4534fce2d75443b16f5ef7593e55a238cd29211e1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.212/tune-server-v0.8.212-macos-x86_64.tar.gz"
      sha256 "75373aaaa7fa14b7143168f14be0bf80109e17403465093adf4a2852e7e8eb4e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.212/tune-server-v0.8.212-linux-aarch64.tar.gz"
      sha256 "8e1318308e0f596c0cdbf8df4d7bcaa2b157904f712c7c2337488c33caa526c8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.212/tune-server-v0.8.212-linux-x86_64.tar.gz"
      sha256 "b3d6e487bafbdec975dafcfc31469fb48aa2500bad706f07224f20181c0532ad"
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
      Tune Server v0.8.212 (Rust) installed!

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
