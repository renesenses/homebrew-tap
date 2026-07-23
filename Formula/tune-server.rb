class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.369"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.369/tune-server-v0.8.369-macos-aarch64.tar.gz"
      sha256 "a152fab4e0ac355cc4ddcce360ff6674c0f6d139a1708c2eb7f723b5c5a3b86d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.369/tune-server-v0.8.369-macos-x86_64.tar.gz"
      sha256 "45e5845c6e4d5c16c951dd502c7ed04b4271f3a9ffc816f483a42edc96dc375c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.369/tune-server-v0.8.369-linux-aarch64.tar.gz"
      sha256 "f64fb61a1b0c48ae1c314b8fbf4661cdd5e9b2e98f582fc541f366388326d079"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.369/tune-server-v0.8.369-linux-x86_64.tar.gz"
      sha256 "a09e8e8d22cee1ba01a613e4f6d12c174c58610d71ff32739c390e163b710807"
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
      Tune Server v0.8.369 (Rust) installed!

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
