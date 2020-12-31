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
    desktopManager.gnome3.enable = true;

    services.xserver.displayManager.sessionCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
      ${pkgs.xorg.xrandr}/bin/xrandr --auto
    '';
  };

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
  ];
}
