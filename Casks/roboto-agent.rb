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

  version "0.22.0"
  if OS.mac?
    sha256 arm: "47627b05fd857cc2a6ae15e14f6d0d645a5a27f5f8bdbf8fe32a610c7bb994ff",
           intel: "0f56f2268626df3304697bf41a5e06a2f7c5cdd8a26c2fc16860562526fbc78d"
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
