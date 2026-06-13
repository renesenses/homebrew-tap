class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.97"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.97/tune-server-v0.8.97-macos-aarch64.tar.gz"
      sha256 "b1a76652d43b05413f7349e69fe30a702953d5eddf417934adfbebfb3d2d86bc"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.97/tune-server-v0.8.97-macos-x86_64.tar.gz"
      sha256 "12c4728d7d00ce9fa0720020ca34c3da9254b47c66d74351285a2d50d7420454"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.97/tune-server-v0.8.97-linux-aarch64.tar.gz"
      sha256 "a7390fb56b25f6bba11fe874a4479c4ec702fee971b874f1a0bb1e23953e58d9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.97/tune-server-v0.8.97-linux-x86_64.tar.gz"
      sha256 "4e8f2698b96ff46983598e568ea5406812a89ad23857a27600d4d92c0568d937"
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
      Tune Server v0.8.97 (Rust) installed!

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
