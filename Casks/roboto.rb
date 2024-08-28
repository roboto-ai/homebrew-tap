cask "roboto" do
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
      "roboto-#{@@os}-#{@@arch}"
    end
  end

  version "0.7.0"
  if OS.mac?
    sha256 arm: "5b809ee5c3d7d113d36d89617f5afc4ac2656648b5080d1b880872e469122ca2",
           intel: "02a9d77e878064c4fcc36e1ad2a2306eb34e4dd86e40cbafe8ab772c2e779183"
  else
    # Casks not supported on Linux: https://github.com/Linuxbrew/brew/issues/742
    # sha256 arm: "...",
    #        intel: "..."
  end
  url "https://github.com/roboto-ai/roboto-python-sdk/releases/download/v#{version}/roboto-#{Utils.os}-#{Utils.arch}",
      verified: "https://github.com/roboto-ai/"

  name "Roboto"
  desc "Command line interface for interacting with Roboto AI"
  homepage "https://roboto.ai"

  depends_on arch: [:arm64, :x86_64]

  binary Utils.binary, target: "roboto"

  preflight do
    target = config.binarydir / "roboto"
    if target.exist? && !target.symlink?
      opoo "replacing self-updated #{target}"
      target.delete
    end
  end

  postflight do
    Quarantine.release!(download_path: "#{caskroom_path}/#{version}/#{Utils.binary}") if Quarantine.available?
  end
end
