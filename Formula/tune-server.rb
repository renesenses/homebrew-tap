class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.39"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.39/tune-server-v0.8.39-macos-aarch64.tar.gz"
      sha256 "18f1b4598a0b13657a1b71d67d0192c18be3c006b758064864eb4b16a19faaab"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.39/tune-server-v0.8.39-macos-x86_64.tar.gz"
      sha256 "c8252540593a2a8f002df8cc996f31e11c646be57e4d10abf18deed494880cfb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.39/tune-server-v0.8.39-linux-aarch64.tar.gz"
      sha256 "49c230e24a0478880b4ae8f8475b7ef8e8ec491afe4f8d7b52abd647c8ae6c0c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.39/tune-server-v0.8.39-linux-x86_64.tar.gz"
      sha256 "442234c208a0dcc8f1126ea3be2595229f56f324dc0c517760614b3307b3d8fa"
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
      Tune Server v0.8.39 (Rust) installed!

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
