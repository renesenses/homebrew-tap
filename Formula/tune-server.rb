class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.55"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.55/tune-server-v0.8.55-macos-aarch64.tar.gz"
      sha256 "a6d913c0c113f5fe85ba98ca31334f251bd91f7d606c4c7621e995d8afdb7891"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.55/tune-server-v0.8.55-macos-x86_64.tar.gz"
      sha256 "83393eed88fb6a85b7df1576d9071c00d035edbfc258dfcf752bf8ae1457b49b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.55/tune-server-v0.8.55-linux-aarch64.tar.gz"
      sha256 "0ab021c53e02d7674b0fe79899fdebee6bf5875bad1dad34036a05200558b3a4"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.55/tune-server-v0.8.55-linux-x86_64.tar.gz"
      sha256 "1d73688d826fd56f6df01e6d608f91473e9b5473341328ddc2090d0b1bb80975"
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
      Tune Server v0.8.55 (Rust) installed!

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
