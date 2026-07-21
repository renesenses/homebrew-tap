class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.355"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.355/tune-server-v0.8.355-macos-aarch64.tar.gz"
      sha256 "9e240dc34bcfc392ba83ef7ea0218ad8d0fd2b7938804cc14d94030d6cdcb1e1"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.355/tune-server-v0.8.355-macos-x86_64.tar.gz"
      sha256 "58c8abd2b46751d158c8bb0fb6b98a8611d74d70866229012bd94b44408749cb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.355/tune-server-v0.8.355-linux-aarch64.tar.gz"
      sha256 "59cf153a1fba966c9958dfaa7d85962063f2b310128ed29042f09140cc8f8445"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.355/tune-server-v0.8.355-linux-x86_64.tar.gz"
      sha256 "9fece6ec0206421a3164319c0c1875221eee3fef8fd74bc57a07308c05487d94"
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
      Tune Server v0.8.355 (Rust) installed!

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
