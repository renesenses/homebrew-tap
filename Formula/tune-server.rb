class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.362"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.362/tune-server-v0.8.362-macos-aarch64.tar.gz"
      sha256 "1347261c664d8bb37d43bfd38bd7d91aecc9f511899b25179ab1dc5156fb9059"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.362/tune-server-v0.8.362-macos-x86_64.tar.gz"
      sha256 "d742a42f6a6e96a3e0c5cd04f2905c1520116637b63e10d8e6ba8378a03b8c64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.362/tune-server-v0.8.362-linux-aarch64.tar.gz"
      sha256 "47970b26d110693da826026827a8e274885d55de4332ee4381c45fad1cdf277e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.362/tune-server-v0.8.362-linux-x86_64.tar.gz"
      sha256 "596a07fc4d2996749ba3afec5ffef8046f7fab74c95167aa74ca634ee9a01970"
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
      Tune Server v0.8.362 (Rust) installed!

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
