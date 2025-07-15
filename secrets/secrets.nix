let
  # Using SSH ed25519 key for agenix
  mbrock = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJD7B4saBw7XXHcNMeO8MVudPSUDWwzje5y0lLQPP7Ub mikael@brockman.se";
in
{
  "nt-api-keys.age".publicKeys = [ mbrock ];
}