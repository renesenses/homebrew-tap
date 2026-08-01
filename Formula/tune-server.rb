class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.37"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.37/tune-server-v0.9.37-macos-aarch64.tar.gz"
      sha256 "ee33116694eacd310b7561d9830a7fad9a5b86bf353c0081db398d41b766a8e2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.37/tune-server-v0.9.37-macos-x86_64.tar.gz"
      sha256 "81a87133f23f46d17b7a1f61da842b9ea9a933da3b33cf470d02ff719c7d34a9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.37/tune-server-v0.9.37-linux-aarch64.tar.gz"
      sha256 "82e0afc544cde612658595761054d1ed11af55a0178eb41ed5d44f60326053c6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.37/tune-server-v0.9.37-linux-x86_64.tar.gz"
      sha256 "ad088072959c1dc1160fac129227367a254967da28a7d29b8603cb04a3ae5eb4"
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
      Tune Server v0.9.37 (Rust) installed!

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
