class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.10"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.10/tune-server-v0.8.10-macos-aarch64.tar.gz"
      sha256 "e83da45addb7b04a4c076fbcc396fb52db36509aad508f6f787f9ea5a5676911"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.10/tune-server-v0.8.10-macos-x86_64.tar.gz"
      sha256 "d8e7de26f2547c092a0a845afdd970c1dff35ca5e84f510f21d0b627fdae3efb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.10/tune-server-v0.8.10-linux-aarch64.tar.gz"
      sha256 "dc03cd33869589bbda3d2907926afd950d5f31d68e13b1da41c3162f42d42e6f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.10/tune-server-v0.8.10-linux-x86_64.tar.gz"
      sha256 "f811188180f6a6a24af86154a9ae557ebc62f1aec4a5034d056d67882a24c5c1"
    end
  end

  depends_on "ffmpeg"

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
      Tune Server v0.8.10 (Rust) installed!

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
