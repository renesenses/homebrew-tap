class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.56"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.56/tune-server-v0.8.56-macos-aarch64.tar.gz"
      sha256 "fc4a41c946636a43b457cd82cdea7f4896161b5a15023a38073df98d38856924"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.56/tune-server-v0.8.56-macos-x86_64.tar.gz"
      sha256 "dcfb89444a6f8c4561ed9d9a8c5ff32895ad28ab5e1ecfe8ce70538ceb669f04"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.56/tune-server-v0.8.56-linux-aarch64.tar.gz"
      sha256 "328d8e3f64ed02e01bed1e38204a0c9e904fc25310307ae7f45a27766f5a5775"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.56/tune-server-v0.8.56-linux-x86_64.tar.gz"
      sha256 "4a8f2d01f8a929625186995b6c374dfaed3e3f29f7b21e1dbcdfb50358f3df28"
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
      Tune Server v0.8.56 (Rust) installed!

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
