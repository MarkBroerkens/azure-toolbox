#!/bin/sh
# https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.3

# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update
brew install --cask powershell
brew upgrade powershell --cask
pwsh --version

echo "SUCESSFULLY installed Powshell"

pwsh -Command Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
echo "SUCESSFULLY installed module Az from PSGallery"


# Add the tap for bicep
brew tap azure/bicep

# Install the tool
brew install bicep


echo "login to your account using Connect-AzAccount"
