class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.237"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.237/tune-server-v0.8.237-macos-aarch64.tar.gz"
      sha256 "1b228e15f27c9fc6439e85a05e453e7afa51397ecef16c9d09f92cde00316be3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.237/tune-server-v0.8.237-macos-x86_64.tar.gz"
      sha256 "cf33f8d94805c6aefd488f6a0a55128ae7c29bcf75a6553647cced15eac01c4b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.237/tune-server-v0.8.237-linux-aarch64.tar.gz"
      sha256 "91a2cf9768e823287fc109052d48c4657aae26f6244ef472800a6c73ebc9ac1b"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.237/tune-server-v0.8.237-linux-x86_64.tar.gz"
      sha256 "afc022546ec07201fe8ff9571219f9db36ed833ef635724e407b9048b9bc483a"
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
      Tune Server v0.8.237 (Rust) installed!

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
