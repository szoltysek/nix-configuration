{ config, pkgs, ... }:

{
  home.username = "ti";
  home.homeDirectory = "/home/ti";

  home.stateVersion = "26.05"; 

  programs.home-manager.enable = true;
}
