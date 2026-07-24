class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.5/tune-server-v0.9.5-macos-aarch64.tar.gz"
      sha256 "d5ec748b3d9d6df2d22a7c8eec870388b14c0cb276603e5c8bcccd899ba82514"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.5/tune-server-v0.9.5-macos-x86_64.tar.gz"
      sha256 "36f5e01ec60eb2f1fef27cc596d2212421ba6eb88c0f4c9aa84f96bfb2a97ab2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.5/tune-server-v0.9.5-linux-aarch64.tar.gz"
      sha256 "fe1d673063efb0b0f4c266ad8c7162914b0ed60ae769ece9691abe1f3017d2f7"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.5/tune-server-v0.9.5-linux-x86_64.tar.gz"
      sha256 "c7662e9bf8e67dc05bcc87ff010eb52db589620e95670b8b259ba01a0291d02e"
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
      Tune Server v0.9.5 (Rust) installed!

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
