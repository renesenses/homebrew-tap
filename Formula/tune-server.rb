class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.9"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.9/tune-server-v0.9.9-macos-aarch64.tar.gz"
      sha256 "0b16665ed981eadaa94df114ef59fd16122b6b91a83d212b403692dd12eed100"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.9/tune-server-v0.9.9-macos-x86_64.tar.gz"
      sha256 "ed78521719e33b13a2781f670445a381c1fb3361eb9bad8373652da734011eac"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.9/tune-server-v0.9.9-linux-aarch64.tar.gz"
      sha256 "4e5ac1d01eae512c39331d1dde8efe1aa85a4d46ef2ecc54d4359416dad14f27"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.9/tune-server-v0.9.9-linux-x86_64.tar.gz"
      sha256 "fdd7bf9928e8865068798ca159d361c2e592f4a2aaaca786560d3ae4db2856ac"
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
      Tune Server v0.9.9 (Rust) installed!

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
