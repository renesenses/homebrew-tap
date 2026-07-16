class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.317"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.317/tune-server-v0.8.317-macos-aarch64.tar.gz"
      sha256 "091f20bb8d054ab40d3e8e92e53b02694ae86236fa2b5a5a8ba0a7b1161158dd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.317/tune-server-v0.8.317-macos-x86_64.tar.gz"
      sha256 "846b76c661f6103a7e77dbaef6b1d77636d392bd15de49351e219fe3f56e018d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.317/tune-server-v0.8.317-linux-aarch64.tar.gz"
      sha256 "acdb20cf49ab10073089e8d7085050548473894998358904a5b474e0a25f1e47"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.317/tune-server-v0.8.317-linux-x86_64.tar.gz"
      sha256 "c035f3d2cba38d51df9edac788cba5127bf2f505bde1d7bc4ba9ba707fa543ee"
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
      Tune Server v0.8.317 (Rust) installed!

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
