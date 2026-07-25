class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.10"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.10/tune-server-v0.9.10-macos-aarch64.tar.gz"
      sha256 "e565ddd1b20ebbdd236a023d3783e9284c25c7f9e49fb1a3ccf639ee9dfecc91"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.10/tune-server-v0.9.10-macos-x86_64.tar.gz"
      sha256 "f0a4eef158ad44748ef58e8525b3886262baadca03dd9f6d7cc709fd6d062ca0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.10/tune-server-v0.9.10-linux-aarch64.tar.gz"
      sha256 "e3cb9e330404560b4a1e587d8b4639612c0c7db0607315578c65eea80c1245b6"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.10/tune-server-v0.9.10-linux-x86_64.tar.gz"
      sha256 "28183ec517f51eee95e1df082babb1b1a033805e565672c16ef0b050d19275bf"
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
      Tune Server v0.9.10 (Rust) installed!

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
