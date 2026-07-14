class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.308"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.308/tune-server-v0.8.308-macos-aarch64.tar.gz"
      sha256 "433a3cbc65216aabb54a99bf93cb34a3286d6b607524ea1b79c27903600bc9f2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.308/tune-server-v0.8.308-macos-x86_64.tar.gz"
      sha256 "7837b51bef045189ce07b9b02ec7751806d5915f070440c21c6302c9c64c8514"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.308/tune-server-v0.8.308-linux-aarch64.tar.gz"
      sha256 "8deb259dbff1a6ca8916bfd03b0fb1ff6f4e05380c093350ee5c60f15a950b16"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.308/tune-server-v0.8.308-linux-x86_64.tar.gz"
      sha256 "2b31e7022d155919e2751cee29aee6dddbd0a14d625cd4a68d908b53db7bf6d9"
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
      Tune Server v0.8.308 (Rust) installed!

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
