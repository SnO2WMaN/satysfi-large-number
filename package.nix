{pkgs, ...}:
pkgs.satyxin.buildPackage {
  name = "large-number";
  src = ./.;
  sources = {
    dirs = ["./src"];
  };
  deps = [];
}
