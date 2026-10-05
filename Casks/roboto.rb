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

  version "0.59.0"
  if OS.mac?
    sha256 arm: "a2a89d3760cf24d21b21b0f33309488459e1b7d9b6f561ef923d2eae0c61a46c",
           intel: "e64827e156a62e51cb72e98fa22b8dcb90ca2166126bd1d7ab95ddf54271ff54"
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
