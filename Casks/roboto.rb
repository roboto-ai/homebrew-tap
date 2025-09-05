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

  version "0.26.1"
  if OS.mac?
    sha256 arm: "33cf45b1c493054bba491a8e9a6391150a0dd12b7acd9936710b2b6959a9285c",
           intel: "cf9a6fa5e87b9a67ef17641caff891d962c350369d2f5988019b811f9456da80"
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
