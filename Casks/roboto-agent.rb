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

  version "0.13.0"
  if OS.mac?
    sha256 arm: "bebf42c61c73a1d05911b5308bc3f0083ca13741be8e97180602bd11e58cea7f",
           intel: "9d638bc8498ea5dc25a6f06e37c68e26863054abddfcfa2690a0f0842a1e1f52"
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
