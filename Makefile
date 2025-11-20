.PHONY: all switch build dry-run update gc rollback fmt edit
all: switch
switch:; sudo nixos-rebuild switch --flake . -L
build:; sudo nixos-rebuild build --flake .#lapland
dry-run:; sudo nixos-rebuild dry-run --flake .#lapland
update:; nix flake update
gc:; sudo nix-collect-garbage -d
rollback:; sudo nixos-rebuild switch --rollback
fmt:; find . -name '*.nix' -type f | xargs nix fmt
edit:; $$EDITOR nixos-base.nix niri.kdl
