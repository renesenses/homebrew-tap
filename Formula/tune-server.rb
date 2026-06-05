class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.45"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "5af81ac8914c38ea00113bb8126f718ccddd2b94426451c02e8aefe7c6b87c48"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "db7474c198be367958243f3f81653a7315cbe031b0f623478bd6e6fbd359d7da"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "4c9745e53a28157eda262c7565f5fb3599be92c02943e4cdb80f13c2f7b0671e"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.45/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "4148dd8ee6eb3e1b975c96e3de8ce213c00f23140fa5231f3f508cdc77f161e9"
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
      Tune Server v0.8.45 (Rust) installed!

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
