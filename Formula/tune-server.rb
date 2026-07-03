class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.240"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.240/tune-server-v0.8.240-macos-aarch64.tar.gz"
      sha256 "b846779be95ef56b5a3c9ea60361058fd8acb16881822d9129d8b1bf3e8fe243"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.240/tune-server-v0.8.240-macos-x86_64.tar.gz"
      sha256 "76d0fe660d4efdbec66a20632380dd12a8a30229457b708b73511de14ac2e40c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.240/tune-server-v0.8.240-linux-aarch64.tar.gz"
      sha256 "84b5db6e0e3c488de47da929c340cf335a912d3847c608ad254acac8e8eb40b7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.240/tune-server-v0.8.240-linux-x86_64.tar.gz"
      sha256 "ea770178d1e72ccc826bf561372fcaf22255a64de5cc8d7929339c9f6dcc0393"
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
      Tune Server v0.8.240 (Rust) installed!

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
