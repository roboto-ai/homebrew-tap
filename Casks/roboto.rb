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

  version "0.62.0"
  if OS.mac?
    sha256 arm: "dde439b68b017c0ea4b3e8efa643b0bfbfff88f91913d4d4a3cccf7f6f2b7693",
           intel: "f17a580213582db4bd7af3ffc99ac8615e8fa34da047d955a420aaad30063ccf"
  else
    # Casks not supported on Linux: https://github.com/Linuxbrew/brew/issues/742
    # sha256 arm: "...",
    #        intel: "..."
  end
  url "https://github.com/roboto-ai/roboto-python-sdk/releases/download/v#{version}/roboto-#{Utils.os}-#{Utils.arch}"

  name "Roboto"
  desc "Command line interface for interacting with Roboto AI"
  homepage "https://roboto.ai"

  depends_on arch: [:arm64, :x86_64]

  binary Utils.binary, target: "roboto"

  # Upgrades and reinstalls unlink the previous version before this runs, so a `roboto` here is a separate copy
  # of the CLI that Homebrew won't replace, most likely a downloaded release binary or a pip install.
  preflight_steps do
    if_path_exists "bin/roboto", base: :homebrew_prefix do
      warn "{{HOMEBREW_PREFIX}}/bin/roboto already exists and isn't from this cask, so Homebrew won't replace it. " \
           "You can remove or move it, then try again."
    end
  end

  # The release binary is only ad-hoc signed, so Gatekeeper blocks it while it carries the quarantine
  # attribute Homebrew puts on cask downloads.
  postflight_steps do
    on_macos do
      run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{staged_path}}"]
    end
  end
end
