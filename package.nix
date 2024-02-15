{
  lib,
  buildRosPackage,
  cmake,
  roscpp,
  #boost,
  protobuf,
  catkin,
  tf,
  gazebo,
}: let
  name = "livox_laser_simulation";
  version = "1.0.0";
in
  buildRosPackage {
    pname = name;
    inherit version;

    src = ./.;

    buildType = "catkin";
    #buildType = "cmake";
    buildInputs = [
      #cmake
      #protobuf
      #roscpp
      gazebo
      catkin
      tf
    ];

    meta = {
      description = "Livox ROS Laser Simulation";
      license = with lib.licenses; [bsdOriginal];
    };
  }
