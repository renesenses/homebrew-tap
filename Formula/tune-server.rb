class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.22"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.22/tune-server-v0.9.22-macos-aarch64.tar.gz"
      sha256 "90c8a1aaf7189142898f374cd6e1e11c339a3e6be86017a688061467e18e71d0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.22/tune-server-v0.9.22-macos-x86_64.tar.gz"
      sha256 "771c1a7a1a6d80b8c6807f65051dd342c3d34d14a4333d0c8d297aa5d914a54e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.22/tune-server-v0.9.22-linux-aarch64.tar.gz"
      sha256 "9f86fdbdc09a344323f7cf9d28b32247179ad609780ab39e83dc44c7914afac6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.22/tune-server-v0.9.22-linux-x86_64.tar.gz"
      sha256 "cfb5af48ba942b1edf745cf2229d73dde7afe21e1350ff0ec804b1b47850236e"
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
      Tune Server v0.9.22 (Rust) installed!

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
