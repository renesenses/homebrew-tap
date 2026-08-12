class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.70"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.70/tune-server-v0.9.70-macos-aarch64.tar.gz"
      sha256 "9737bfee7d164415254f599d8ca45e9249af1d39febf5f7f30dcb44df2f4ba89"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.70/tune-server-v0.9.70-macos-x86_64.tar.gz"
      sha256 "297916373d06a7dc8cf914995b5c2f4462be055b0668bd501df027c95519ca76"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.70/tune-server-v0.9.70-linux-aarch64.tar.gz"
      sha256 "b4463c56a084e9609ec6deebb01ce166791b28c8729c92ef0866e15ab2f5a3f3"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.70/tune-server-v0.9.70-linux-x86_64.tar.gz"
      sha256 "9d8c28079d6ee572df31233eae01c024e7e91a6908930e7273f010243ef5cad7"
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
      Tune Server v0.9.70 (Rust) installed!

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
