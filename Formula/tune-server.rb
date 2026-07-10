class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.289"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.289/tune-server-v0.8.289-macos-aarch64.tar.gz"
      sha256 "93d17a67e9b9dbfb209acb8976e04f5713d16e53ee5fa3f7b74ac389849f1daa"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.289/tune-server-v0.8.289-macos-x86_64.tar.gz"
      sha256 "2846b6b4ddbb06df864f31d2fb404b1b127ecbf52a395fbf0da8851dd7b16a36"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.289/tune-server-v0.8.289-linux-aarch64.tar.gz"
      sha256 "053cc8566e0e5b452048966a51e21ad6c9061b7561201a18ef34a5abe9511be5"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.289/tune-server-v0.8.289-linux-x86_64.tar.gz"
      sha256 "72cc0b60723c26cb8f2f98921911f70abb0f6bfc2500eae2bd7ae41a24824867"
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
      Tune Server v0.8.289 (Rust) installed!

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
