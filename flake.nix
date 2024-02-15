{
  description = "ROS overlay for the Nix package manager";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #nixpkgs.url = "github:orivej/nixpkgs/qtwebkit";
    nix-ros-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nix-ros-overlay,
  }: let
    system = "x86_64-linux";
    livox_distro_overaly = final: prev: {
      livox-laser-simulation = final.callPackage ./package.nix {};
    };

    ros-overlay = self: super: {
      rosPackages =
        super.rosPackages
        // {
          noetic = super.rosPackages.noetic.overrideScope livox_distro_overaly;
        };
    };
    pkgs = import nix-ros-overlay.inputs.nixpkgs {
      inherit system;
      overlays = [
        nix-ros-overlay.overlays.default
        ros-overlay
      ];
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs;
      with rosPackages.noetic;
      with pythonPackages; [
        glibcLocales
        (buildEnv
          {
            paths = [
              catkin
              catkin-tools
              cmake
              roscpp
              tf
              ros-core
              gazebo
              #livox-laser-simulation
            ];
          })
      ];
      ROS_HOSTNAME = "localhost";
      ROS_MASTER_URI = "http://localhost:11311";
    };
    overlays.default = ros-overlay;
    packages.${system}.default = pkgs.rosPackages.noetic.livox-laser-simulation;

    nixConfig = {
      extra-substituters = ["https://cache.nixos.org" "https://ros.cachix.org"];
      extra-trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="];
    };
  };
}
