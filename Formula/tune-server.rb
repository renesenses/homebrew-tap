class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.9.62"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.62/tune-server-v0.9.62-macos-aarch64.tar.gz"
      sha256 "f657668ebe99db47f0d67110a26a059e44dd69f463114e6e07f13c788714882d"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.62/tune-server-v0.9.62-macos-x86_64.tar.gz"
      sha256 "100bc4e2b507d9c406b46792f5c9e1a294f5fd0fe8db9fe1b51dd19eeadb4654"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.62/tune-server-v0.9.62-linux-aarch64.tar.gz"
      sha256 "c0a41203f0acc1842dd4bd1168d4a25a74c6459af23e066f7460f24e8d4162ae"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.9.62/tune-server-v0.9.62-linux-x86_64.tar.gz"
      sha256 "b871520c45b517b59a5fe726b413656108cf3c54b99e5964d4df17a1035aba1b"
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
      Tune Server v0.9.62 (Rust) installed!

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
