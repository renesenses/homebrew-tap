class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.363"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.363/tune-server-v0.8.363-macos-aarch64.tar.gz"
      sha256 "3803830df68bdd7b8368e57cf5daffac458f6edb31e31e08b7f109bc73bc87fb"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.363/tune-server-v0.8.363-macos-x86_64.tar.gz"
      sha256 "b705b7366902c7cddefb441f5212b5264fc56d1929aa985d3862e804f0e2f898"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.363/tune-server-v0.8.363-linux-aarch64.tar.gz"
      sha256 "668f8cb92310a3e96b0caeec275c0f62392f49040dc78381573faf389adab6f5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.363/tune-server-v0.8.363-linux-x86_64.tar.gz"
      sha256 "95d0d28bf92c694d679d580c05980198b1d4dcaea30bb0717055f71ef51e23c6"
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
      Tune Server v0.8.363 (Rust) installed!

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
