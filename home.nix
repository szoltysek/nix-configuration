{ config, pkgs, ... }:

{
  home.username = "ti";
  home.homeDirectory = "/home/ti";

  home.stateVersion = "25.11"; 

  programs.home-manager.enable = true;
}
