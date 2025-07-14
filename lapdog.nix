{ config, lib, pkgs, ... }:

{
  imports = [ ./nixos-base.nix ];
  
  networking.hostName = "lapdog";
}