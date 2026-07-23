class TuneServer < Formula
  desc "Multi-room music server (Rust) with DLNA/UPnP, streaming, and web UI"
  homepage "https://mozaiklabs.fr"
  version "0.8.368"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.368/tune-server-v0.8.368-macos-aarch64.tar.gz"
      sha256 "dbd9f17c7dff75684b2219ddd614564e8124167f834ab7f70c199041b92a5619"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.368/tune-server-v0.8.368-macos-x86_64.tar.gz"
      sha256 "eae5c0286d03a736367a28beca97ee42ab849e59300d01858af0d49b3ff70d69"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.368/tune-server-v0.8.368-linux-aarch64.tar.gz"
      sha256 "3abf6dca5c7e2bf0e53cdc9136d5335258e57ec85eb77ddca08ac7288d1c3aee"
    else
      url "https://github.com/renesenses/tune-server-rust/releases/download/v0.8.368/tune-server-v0.8.368-linux-x86_64.tar.gz"
      sha256 "572c19c4d6936fb2b24a6a933f2795bd170b8770348084beacbee7fe6cbf8637"
    end
  end

  def install
    bin.install "tune-server"
    pkgshare.install "web"

    (bin/"tune-server-launcher").write <<~'BASH'
      #!/bin/bash
      export TUNE_PORT="${TUNE_PORT:-8888}"
      SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
      PREFIX="$(dirname "$SELF_DIR")"
      export TUNE_WEB_DIR="${PREFIX}/share/tune-server/web"
      exec "${SELF_DIR}/tune-server" "$@"
    BASH
    chmod 0755, bin/"tune-server-launcher"
  end

  def post_install
    (var/"tune-server").mkpath
    (var/"tune-server/artwork_cache").mkpath
  end

  def caveats
    <<~EOS
      Tune Server v0.8.368 (Rust) installed!

      Start: tune-server-launcher
      Web UI: http://localhost:8888

      Background service: brew services start tune-server
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
