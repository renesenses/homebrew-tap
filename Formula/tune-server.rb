class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.84"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.84/tune-server-v0.8.84-macos-aarch64.tar.gz"
      sha256 "64f91a6817d7d06693728b1dc63c19256a4e1cc012b28c17a590311f15875e8d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.84/tune-server-v0.8.84-macos-x86_64.tar.gz"
      sha256 "e409983607b43fd3be6fe23e7acadea2e13e50716a7aeae65fb75899088c84d7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.84/tune-server-v0.8.84-linux-aarch64.tar.gz"
      sha256 "5f0a28e0e79ecd13c4d2698449639a9d47ef7ffadc1703e559178c4185816e00"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.84/tune-server-v0.8.84-linux-x86_64.tar.gz"
      sha256 "e39678ff310faef080ef9fd959e1778119cc2f2da100da750bd54241f0e0f888"
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
      Tune Server v0.8.84 (Rust) installed!

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
