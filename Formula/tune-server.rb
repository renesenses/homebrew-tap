class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.54"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.54/tune-server-v0.8.54-macos-aarch64.tar.gz"
      sha256 "e2903e582ba59003699cd2105b2c7bc3a94a82999a670c3b03489c0e5d1043f0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.54/tune-server-v0.8.54-macos-x86_64.tar.gz"
      sha256 "4af1eff5531266044cb7f4571c8676376c4e721a226d97b048a48871e4a2c2a9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.54/tune-server-v0.8.54-linux-aarch64.tar.gz"
      sha256 "773f5f9805af4021d06809d6a2ccb60c03267eb376781088b1d52aa7d44ff8b2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.54/tune-server-v0.8.54-linux-x86_64.tar.gz"
      sha256 "0334f13ad1f7338d65f389fe863265bc46d868d887ab8aaf0836fee83e15de10"
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
      Tune Server v0.8.54 (Rust) installed!

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
