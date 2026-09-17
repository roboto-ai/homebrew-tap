cask "roboto-agent" do
  # Force commit
  module Utils
    @@os = OS.mac? ? "macos" : OS.kernel_name.downcase
    @@arch = Hardware::CPU.arch.to_s.sub("arm64", "aarch64")
    def self.os
      @@os
    end
    def self.arch
      @@arch
    end
    def self.binary
      "roboto-agent-#{@@os}-#{@@arch}"
    end
  end

  version "0.57.0"
  if OS.mac?
    sha256 arm: "fb86b67cdd81f3aa872aabafb62de04c21a3da9001fb1392e39b44dcd77dccee",
           intel: "5181f3a3af14a5895eb047143c1d683ecc613f75a6a1301af1bf49b861e9b64d"
  else
    # Casks not supported on Linux: https://github.com/Linuxbrew/brew/issues/742
    # sha256 arm: "...",
    #        intel: "..."
  end
  url "https://github.com/roboto-ai/roboto-python-sdk/releases/download/v#{version}/roboto-agent-#{Utils.os}-#{Utils.arch}",
      verified: "https://github.com/roboto-ai/"

  name "Roboto Agent"
  desc "Device agent for automatically uploading data to Roboto"
  homepage "https://roboto.ai"

  depends_on arch: [:arm64, :x86_64]

  binary Utils.binary, target: "roboto-agent"

  preflight do
    target = config.binarydir / "roboto-agent"
    if target.exist? && !target.symlink?
      opoo "replacing self-updated #{target}"
      target.delete
    end
  end

  postflight do
    Quarantine.release!(download_path: "#{caskroom_path}/#{version}/#{Utils.binary}") if Quarantine.available?
  end
end
