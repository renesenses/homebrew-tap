class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.50"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.50/tune-server-v0.9.50-macos-aarch64.tar.gz"
      sha256 "e74b57dae820661a0c86c2daf14568052eb3ee14748e7a890038ece15ce5cb9d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.50/tune-server-v0.9.50-macos-x86_64.tar.gz"
      sha256 "615184c700a64207850094b6db2f796b30b732eec28b87bc5238412ecb398091"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.50/tune-server-v0.9.50-linux-aarch64.tar.gz"
      sha256 "b1ac1323cd34233c65f2d65efe461fd2849e6fdba636cbc46d12b4d63ffcd7b0"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.50/tune-server-v0.9.50-linux-x86_64.tar.gz"
      sha256 "489651b2ed4945d94f2f98075cd4850b207c9d0b5153c23213bf80ca0c544279"
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
      Tune Server v0.9.50 (Rust) installed!

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
