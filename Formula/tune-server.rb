class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.243"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.243/tune-server-v0.8.243-macos-aarch64.tar.gz"
      sha256 "3c03265463e4464b574116b55638a131f4ac11ecb8e4726e45926095c9ac3ecc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.243/tune-server-v0.8.243-macos-x86_64.tar.gz"
      sha256 "dad2bb6f46c6a2748a868b3233dd5ef14562a5a77d2078c82f979ee74ef3f282"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.243/tune-server-v0.8.243-linux-aarch64.tar.gz"
      sha256 "ee9632156ddf3ea106212f5d5d44dbcb72839587f4b6894c6a0f31cb7217057c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.243/tune-server-v0.8.243-linux-x86_64.tar.gz"
      sha256 "d909cd23b43dd6598a90840b64ce3c4783989a2a32a3929debcbda21dd41a1bb"
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
      Tune Server v0.8.243 (Rust) installed!

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
