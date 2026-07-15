class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.316"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.316/tune-server-v0.8.316-macos-aarch64.tar.gz"
      sha256 "5a5a306d80e93bc8848d6ec34c8d2255e44d78f282c8d30b4f13742478fa9436"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.316/tune-server-v0.8.316-macos-x86_64.tar.gz"
      sha256 "8b222eb64e32613a73b423b614dec8d540ec3647cf3500f3520bb26ef914f706"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.316/tune-server-v0.8.316-linux-aarch64.tar.gz"
      sha256 "9a4027bf382ad8a296b014b7f17d00b1995de852a2d844d57b4df4579cc142f3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.316/tune-server-v0.8.316-linux-x86_64.tar.gz"
      sha256 "419ba2e3e1e6ee0bf5d3d273f24e307b912e541ee961f110c1aaa4f6f58ddf91"
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
      Tune Server v0.8.316 (Rust) installed!

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
