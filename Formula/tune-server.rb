class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.47"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.47/tune-server-v0.8.42-macos-aarch64.tar.gz"
      sha256 "ae61822a78c862c4500e7632ed93897d63fba1f792840bcc7c342131d59ae286"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.47/tune-server-v0.8.42-macos-x86_64.tar.gz"
      sha256 "f884dcd153d0a628e548eb6a284792c042831a8e13819c5b0b23af1a8682ccc2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.47/tune-server-v0.8.42-linux-aarch64.tar.gz"
      sha256 "efc304fcfd41adec49bd3749941eb0da937c449eb7140954d0c6fa4476e04631"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.47/tune-server-v0.8.42-linux-x86_64.tar.gz"
      sha256 "c4fdada8340a7f737986bc993bc22bdd304d6f79f65b1e7e089da4d49b98fb21"
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
      Tune Server v0.8.47 (Rust) installed!

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
