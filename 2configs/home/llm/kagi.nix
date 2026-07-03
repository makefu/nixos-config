{
  config,
  self,
  pkgs,
  ...
}:
let
  # systemd-nspawn imports credentialFiles under the service's credentials
  # directory. The opencrow service unit inside the container is
  # opencrow.service, so ImportCredential places the token here.
  tokenFile = "/run/credentials/opencrow.service/kagi-session-token";
in
{
  # Kagi session token, managed as a clan/sops secret.
  # Set with: clan secrets set --machine omo opencrow-kagi-session-token
  sops.secrets.opencrow-kagi-session-token = { };

  # Inject the raw session token into the container as a systemd credential.
  services.opencrow.credentialFiles."kagi-session-token" =
    config.sops.secrets.opencrow-kagi-session-token.path;

  services.opencrow.skills.kagi-search = "${self.inputs.mics-skills}/skills/kagi-search";

  services.opencrow.extraPackages = [
    self.inputs.mics-skills.packages.${pkgs.stdenv.hostPlatform.system}.kagi-search
  ];

  # kagi-search reads the token via password_command. cat the credential file
  # directly. The raw token is used verbatim (no "token=" prefix), so the
  # script takes the whole output as the token.
  containers.opencrow.config.systemd.tmpfiles.rules = [
    "d /var/lib/opencrow/.config/kagi 0750 opencrow opencrow -"
    ''f /var/lib/opencrow/.config/kagi/config.json 0640 opencrow opencrow - {"password_command":"cat ${tokenFile}","timeout":30,"max_retries":5}''
  ];
}
