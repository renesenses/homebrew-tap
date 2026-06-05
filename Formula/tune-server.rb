class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.46"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.46/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "6fef860da7287b4788b8fc1384378646013a99d46dec9f46b75e53c1d157f423"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.46/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "955bf30dd1ad8cb6b79ee845d7c994781e847830c8c581c04b0fe4cdcacdb801"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.46/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "971f71db5f09aa09967eae8dc5462653a90f3b52685667bac50e954d2d3611dd"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.46/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "5e4469d3bc8dc432fb85c7a6d2483ead9be2b59e2229c9278f7e60e3a012c823"
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
      Tune Server v0.8.46 (Rust) installed!

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
