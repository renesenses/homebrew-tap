class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.276"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.276/tune-server-v0.8.276-macos-aarch64.tar.gz"
      sha256 "fba57b3dc4ea042098f76ab2098cee70e2101ca76fcaa864e71100c2d6ecd18f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.276/tune-server-v0.8.276-macos-x86_64.tar.gz"
      sha256 "a6a5be5a662961cd2d8cb3ed70ba491bcec766c74e62a8ebb42040598bc0ffb6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.276/tune-server-v0.8.276-linux-aarch64.tar.gz"
      sha256 "c09430ba22eb32e830901c164823ac34bc0802d7b0887a648e8b69b04d0a2c63"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.276/tune-server-v0.8.276-linux-x86_64.tar.gz"
      sha256 "88a38481b58138892f7ea587a60d1ea4d7d6b6b5edc4daa39721c1beaeffe86b"
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
      Tune Server v0.8.276 (Rust) installed!

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
