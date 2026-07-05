class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.259"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.259/tune-server-v0.8.259-macos-aarch64.tar.gz"
      sha256 "cbc3267fe5486e0b204eb217f558e0d35ec0b9f499989f152ba2e564fee3b830"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.259/tune-server-v0.8.259-macos-x86_64.tar.gz"
      sha256 "21ba2f8186292b7a2269d93338fb2250f1fc358861b0715129f3cabebd122429"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.259/tune-server-v0.8.259-linux-aarch64.tar.gz"
      sha256 "074097c97e2a4782bea529c1c00f5189e68957f695210396c27de08f41977d5f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.259/tune-server-v0.8.259-linux-x86_64.tar.gz"
      sha256 "ffdd8580066b37847ef59c5ac06c92b317669236ab9e2ecbb95dde30bfbf09a9"
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
      Tune Server v0.8.259 (Rust) installed!

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
