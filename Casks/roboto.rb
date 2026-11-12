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

  version "0.64.0"
  if OS.mac?
    sha256 arm: "74cbba9fc863c3a41a23d09385d37c9545d9fb7b7891b00ae673b8e76402f5c3",
           intel: "d2281080a400eb2c5904bd9eee0d2945f8716ffe476259f765dbd1e11a7d5874"
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
