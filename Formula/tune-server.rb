class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.66"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.66/tune-server-v0.8.66-macos-aarch64.tar.gz"
      sha256 "1373f4e796f83a9538ee9ce1c67812df09f354a8dc26e738c290bb7f0aadf9f8"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.66/tune-server-v0.8.66-macos-x86_64.tar.gz"
      sha256 "096561ab522c58be933fd9ed70a5b5bb6bc927183d5b748a1dd30297e4b83faf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.66/tune-server-v0.8.66-linux-aarch64.tar.gz"
      sha256 "ab96ffb560c1c70ca5949ccae595204b8f20b7b917ce199f448e7d1e979d1a2c"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.66/tune-server-v0.8.66-linux-x86_64.tar.gz"
      sha256 "4393de85efe7c15a8960fb1d498ea4fadbb776578d1889fdd6b438f7a8e5e698"
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
      Tune Server v0.8.66 (Rust) installed!

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
