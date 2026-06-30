class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.210"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.210/tune-server-v0.8.210-macos-aarch64.tar.gz"
      sha256 "ae410ef2d5b4918304e55192462ac6feb7a35768d4a10d1a5e4dc6971582e1ba"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.210/tune-server-v0.8.210-macos-x86_64.tar.gz"
      sha256 "070406f79fb75f2144d18cb572c3103baa09fadfca80a91d527fc9b5d08f8bd0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.210/tune-server-v0.8.210-linux-aarch64.tar.gz"
      sha256 "aedd4649b71ed86aceccfe84291baaae4e930af69f26af907dae82ef156be304"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.210/tune-server-v0.8.210-linux-x86_64.tar.gz"
      sha256 "875fe9b1b7a3075f622aee5b00b1c1c98b6e454cb56eed0883598516eb020bf6"
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
      Tune Server v0.8.210 (Rust) installed!

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
