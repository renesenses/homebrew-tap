class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.75"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.75/tune-server-v0.9.75-macos-aarch64.tar.gz"
      sha256 "c20245328ac4c15ba8c06c3575a0f13348e2927c27e09cba170ebca55d17d8c0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.75/tune-server-v0.9.75-macos-x86_64.tar.gz"
      sha256 "fd8265923339527f0a6f186d4108fb9d00c4441ee49ca1019158f3b1e8f9e3e7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.75/tune-server-v0.9.75-linux-aarch64.tar.gz"
      sha256 "1be90a6f9c91a89c4f01347084f293f8b8401984474dcb898497455400480e45"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.75/tune-server-v0.9.75-linux-x86_64.tar.gz"
      sha256 "86d5ec2281d69d740449547b2e20529c9e9c82028617cf6b77e4e387bc7090f8"
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
      Tune Server v0.9.75 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server

      Après une mise à jour, redémarrez le serveur :
      brew services restart tune-server (ou relancez tune-server-launcher).

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
