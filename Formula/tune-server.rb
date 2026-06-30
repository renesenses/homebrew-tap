class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.216"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.216/tune-server-v0.8.216-macos-aarch64.tar.gz"
      sha256 "035c0623ffde21980df2b50ca23e88e728cd5c92e141f39b71b24bf713decb17"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.216/tune-server-v0.8.216-macos-x86_64.tar.gz"
      sha256 "3224091cfb6fab20e2e4c0d16ab200996c47753b4d168436fbb1cee64b6ac059"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.216/tune-server-v0.8.216-linux-aarch64.tar.gz"
      sha256 "72a476d71a053fc8bf758ed303493dafc92152cc404067cb6d7b3c84e0ce56ba"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.216/tune-server-v0.8.216-linux-x86_64.tar.gz"
      sha256 "3551ed58361c355233c14bb586be4187d5f9e3f0229eac64f03923206b3051f7"
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
      Tune Server v0.8.216 (Rust) installed!

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
