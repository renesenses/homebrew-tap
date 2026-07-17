class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.329"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.329/tune-server-v0.8.329-macos-aarch64.tar.gz"
      sha256 "86f29a46e8b38d2b35a0ff2fe4e5c7e8d4c18676b537bf34804af6728c0fc189"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.329/tune-server-v0.8.329-macos-x86_64.tar.gz"
      sha256 "88cf7bb81ce60d7a08dae49eed1e9d7e9049abc0c0016f8337aee8194560c0da"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.329/tune-server-v0.8.329-linux-aarch64.tar.gz"
      sha256 "8e229d488f505da9ecde48fe708a87837292d7b899d5b4913abe64a74e4043c0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.329/tune-server-v0.8.329-linux-x86_64.tar.gz"
      sha256 "33782b1f351892c5059fefd68c49c6668b1822353401cb0d5dca9fae292b9fed"
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
      Tune Server v0.8.329 (Rust) installed!

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
