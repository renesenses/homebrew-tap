class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.88"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.88/tune-server-v0.8.88-macos-aarch64.tar.gz"
      sha256 "8f5a7d280f5e099368f1dda6a06450a99bd8143661a8bb50f1490c96d568d981"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.88/tune-server-v0.8.88-macos-x86_64.tar.gz"
      sha256 "9d26809edd759bd1fbc566e3208e568b00e0d09e66e4896ff4578d8c7a0bdd9a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.88/tune-server-v0.8.88-linux-aarch64.tar.gz"
      sha256 "4912966ee55b1685a3d8bd57c33022992349bfcf62db4f4009c2ae4f336a4983"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.88/tune-server-v0.8.88-linux-x86_64.tar.gz"
      sha256 "fa577431a320c3e67554e57e125a58fed9550e410e4fbf91903be6bfca983ab7"
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
      Tune Server v0.8.88 (Rust) installed!

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
