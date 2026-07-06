class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.272"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.272/tune-server-v0.8.272-macos-aarch64.tar.gz"
      sha256 "cabe5bf487c4364d10208c823c0cb19987faceeb6c25890484253795c31b7cfd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.272/tune-server-v0.8.272-macos-x86_64.tar.gz"
      sha256 "e5c1c3ecbcc33647a5fafcf6c71d0604d289ca2bdba78d8e34dfd38c154fa9e3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.272/tune-server-v0.8.272-linux-aarch64.tar.gz"
      sha256 "05cb2ed47e74796a84605d0c97e70056218cf3aae33ccf1b4a85a58e4b0075dc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.272/tune-server-v0.8.272-linux-x86_64.tar.gz"
      sha256 "5d3d9de1cd607d842c5a98395a769f33d5a3f483d80d5ca7d1030d38ba639431"
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
      Tune Server v0.8.272 (Rust) installed!

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
