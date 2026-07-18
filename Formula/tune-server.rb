class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.332"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.332/tune-server-v0.8.332-macos-aarch64.tar.gz"
      sha256 "9daa481c2f6e3a322b9415309ac2ceca24cf04491725ff29011fb99b23026d12"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.332/tune-server-v0.8.332-macos-x86_64.tar.gz"
      sha256 "358af52f3474b3f884e7befd9e7c108eda5507b8f2b65be65ce7009e823340de"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.332/tune-server-v0.8.332-linux-aarch64.tar.gz"
      sha256 "83c14f25e85133b0d2038cacf9be00e5e46ffba5db643bad33cc0740262bc869"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.332/tune-server-v0.8.332-linux-x86_64.tar.gz"
      sha256 "b8c6ba1c9c29d8d7bba668b9b08384c784846c041d94118fa454c544146f67ec"
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
      Tune Server v0.8.332 (Rust) installed!

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
