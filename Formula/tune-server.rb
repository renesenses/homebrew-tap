class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.257"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.257/tune-server-v0.8.257-macos-aarch64.tar.gz"
      sha256 "73eac411d5351c637495af6404b48918a17817e3d0890226dc7615d2070453ae"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.257/tune-server-v0.8.257-macos-x86_64.tar.gz"
      sha256 "ed78e89e635b53a64c42a5844ca61fc0816e4975d9ea334a4cc08b5b93d4ecdd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.257/tune-server-v0.8.257-linux-aarch64.tar.gz"
      sha256 "cc3351d811cafeac56fc6535f909473b0ce9d15312e204477a252c8efeafd1be"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.257/tune-server-v0.8.257-linux-x86_64.tar.gz"
      sha256 "236c1cad9e1cbfab178798dc4a6bcda0d39ceb98ba3fa67e1ccb6215ab7e2204"
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
      Tune Server v0.8.257 (Rust) installed!

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
