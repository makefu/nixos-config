{config, lib, pkgs, ... }:

with import <stockholm/lib>;
{
  options.makefu.server.primary-itf = lib.mkOption {
		type = types.str;
		description = "Primary interface of the server";
	};
}

