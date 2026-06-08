class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.63"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.63/tune-server-v0.8.63-macos-aarch64.tar.gz"
      sha256 "3aa87eaf8edb2487195aa39433a8b24029b1e44395b30affe81ffc4cc089e71f"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.63/tune-server-v0.8.63-macos-x86_64.tar.gz"
      sha256 "640ff89ca504466f0668e7c849796fed0683d2763a11c7f36d18b42c7a60e7e8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.63/tune-server-v0.8.63-linux-aarch64.tar.gz"
      sha256 "0b7e34b6323eb5179d2fac9be27cf3d09e116db0c1d059088b892d6649e7f5d2"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.63/tune-server-v0.8.63-linux-x86_64.tar.gz"
      sha256 "6412fc0a94eb60ca251f4d00fa6a9915245fe995b52e9d6613d362a8d96a4fa4"
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
      Tune Server v0.8.63 (Rust) installed!

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
