{config, ... }:
{
  services.anubis = {
    defaultOptions.settings = {
      USER_DEFINED_DEFAULT = true;
    };
    instances = {
      "anubis".settings = {
        TARGET = "http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";
        DIFFICULTY = 3;
        USER_DEFINED_INSTANCE = true;
        OG_PASSTHROUGH = true;
        SERVE_ROBOTS_TXT = true;
      };

    };
  };

  users.users.nginx.extraGroups = [ config.users.groups.anubis.name ];
}
