class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.281"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.281/tune-server-v0.8.281-macos-aarch64.tar.gz"
      sha256 "189cd7ade06b3ee73750fce08970d0db08933820ad2c7aa67261fad0046e7da3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.281/tune-server-v0.8.281-macos-x86_64.tar.gz"
      sha256 "0af7f8a9482bc01f8a4409cc941f7b5de1aa8bf37325bd5760ea23e2377af982"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.281/tune-server-v0.8.281-linux-aarch64.tar.gz"
      sha256 "c54b31b49a2126a54bc6489cafcdb299c8aa55c48ff612fba020a9b1594eb7ea"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.281/tune-server-v0.8.281-linux-x86_64.tar.gz"
      sha256 "36f416acf72af391bcbe3468ebfb32b16ff0c387cff6b07416984eb4c91b5750"
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
      Tune Server v0.8.281 (Rust) installed!

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
