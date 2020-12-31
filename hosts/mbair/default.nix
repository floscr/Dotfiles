{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
{
  imports = [
    ./hardware-configuration.nix
  ];
  modules = {
    shell = {
      # direnv.enable = true;
      git.enable    = true;
      # gnupg.enable  = true;
      # pass.enable   = true;
      zsh.enable    = true;
    };
  };

  networking.useDHCP = false;

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.sessionCommands = "exec -l $SHELL -c gnome-session";
    desktopManager.gnome3.enable = true;

    # windowManager.bspwm.enable = true;
  };

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
  ];
}
