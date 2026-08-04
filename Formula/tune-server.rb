class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.48"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.48/tune-server-v0.9.48-macos-aarch64.tar.gz"
      sha256 "76673060c94765d6b36ec5595c2acbfabef722621272bad52c6d35ab9ed05a46"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.48/tune-server-v0.9.48-macos-x86_64.tar.gz"
      sha256 "89ace8f6b8b51513f2f24ec9765f8e86493db80166ddf8ea1001eb9c8a2d876b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.48/tune-server-v0.9.48-linux-aarch64.tar.gz"
      sha256 "ee2ef52e0ba2b1543c2f95ed03f4b2707a642bea15715ddccf2025f8d4a298db"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.48/tune-server-v0.9.48-linux-x86_64.tar.gz"
      sha256 "cd6e5b8f21375d0d6fb472d06107b461debfb6d0084cc30f9f94a4e8f1d11f86"
    end
  end

  def install
    bin.install "tune-server"
    pkgshare.install "web"

    (bin/"tune-server-launcher").write <<~EOS
      #!/bin/bash
      export PATH="#{Formula["ffmpeg"].opt_bin}:$PATH"
      export TUNE_PORT="${TUNE_PORT:-8888}"
      export TUNE_WEB_DIR="#{pkgshare}/web"
      exec "#{bin}/tune-server" "$@"
    EOS
    chmod 0755, bin/"tune-server-launcher"
  end

  def post_install
    (var/"tune-server").mkpath
    (var/"tune-server/artwork_cache").mkpath
  end

  def caveats
    <<~EOS
      Tune Server v0.9.48 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

      Legacy Python version: brew install renesenses/tap/tune-server-python
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
