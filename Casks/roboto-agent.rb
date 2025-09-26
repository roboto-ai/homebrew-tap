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

  version "0.27.0"
  if OS.mac?
    sha256 arm: "09c4f1ac8998a2b41816d7112205cb10443c0b97fb22466c70e8929f87a4d690",
           intel: "6fb04c98a94c5b5022bcb074b2ba1817c78fe3ab99f651383ace65c5d7e80ce3"
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
