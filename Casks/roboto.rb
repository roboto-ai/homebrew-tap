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

  version "0.30.0"
  if OS.mac?
    sha256 arm: "ff95ee5be2430c9f170b8e68ce299c4e9fc43b4358af58c55ac524485fb07054",
           intel: "2ee2d3095eb071719e6ce1e24249d940f05b35e1d2bf4b02f3483103a80b2aa5"
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
