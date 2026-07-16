class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.319"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.319/tune-server-v0.8.319-macos-aarch64.tar.gz"
      sha256 "d726e0d64250e2c2a25ed7c4bf9c2d15034de8d98c8cd86baa24dc74979fee28"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.319/tune-server-v0.8.319-macos-x86_64.tar.gz"
      sha256 "5c1354327e9bb3de256698465a37e4c93b8b15fbeb4f682d7d0bc02abec001e4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.319/tune-server-v0.8.319-linux-aarch64.tar.gz"
      sha256 "99c2d888deb7507aa9487688869984d60c72eda247c732fe12b8f0bb297111ee"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.319/tune-server-v0.8.319-linux-x86_64.tar.gz"
      sha256 "1ebd7daa38f9833e67b3dd195b3540b7e8e455088139aab0122905e6eabfc54b"
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
      Tune Server v0.8.319 (Rust) installed!

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
