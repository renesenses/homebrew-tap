class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.271"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.271/tune-server-v0.8.271-macos-aarch64.tar.gz"
      sha256 "d038c06e8e1ff7a3a0970fa6f164aa6991b3cdf8254562e621af5a4a4c79cbd3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.271/tune-server-v0.8.271-macos-x86_64.tar.gz"
      sha256 "46defb3bdfdae18f2323bff450ec9418155892672ddaf0b2eb713515fbba5bd6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.271/tune-server-v0.8.271-linux-aarch64.tar.gz"
      sha256 "458ff86a3d797acacb9cc6a99380381cb78f4fa8fa6a4dfe0817f56060becaa9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.271/tune-server-v0.8.271-linux-x86_64.tar.gz"
      sha256 "2d78042d6be531bef565514a58e4b7ae1b48be0d653bdd34a02fe18219088d99"
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
      Tune Server v0.8.271 (Rust) installed!

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
