class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.153"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.153/tune-server-v0.8.153-macos-aarch64.tar.gz"
      sha256 "387e05acfa32a4a278aa61f676319ff8e94b59e7a595141785fea8b53509144a"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.153/tune-server-v0.8.153-macos-x86_64.tar.gz"
      sha256 "3bdfb665b587f1785f502893ed87fbc38be7f9edc0ec46f45d67567a7068b313"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.153/tune-server-v0.8.153-linux-aarch64.tar.gz"
      sha256 "bfc319fea9ad13378985e40223e0c7988c64e31a6af398ad41738f4fc61e49bd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.153/tune-server-v0.8.153-linux-x86_64.tar.gz"
      sha256 "3f25e8e431af3c077eef31ca257d1397c60b50f871b2b11f01846c1eeaf4c098"
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
      Tune Server v0.8.153 (Rust) installed!

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
