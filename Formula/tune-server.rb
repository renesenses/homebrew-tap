class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.166"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.166/tune-server-v0.9.166-macos-aarch64.tar.gz"
      sha256 "3f2a4e341bdbf7229253d42d4e0f7dad5ebce68df1fa818088121993df5f6fa9"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.166/tune-server-v0.9.166-macos-x86_64.tar.gz"
      sha256 "06159282ed901839a451e977fc8d46e3a5cb0b97d61dfb84f95173763eb570a5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.166/tune-server-v0.9.166-linux-aarch64.tar.gz"
      sha256 "b22043afc6ec5d48e97831942ad81f8e5c3993cbdc51e360617d5fc34d293ede"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.166/tune-server-v0.9.166-linux-x86_64.tar.gz"
      sha256 "7900bb6809083beabf49eb782186598ffaeab0c31caab10c4533267f0fd04c0e"
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
      Tune Server v0.9.166 (Rust) installed!

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
