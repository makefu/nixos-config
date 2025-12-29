{ config, lib, pkgs, ... }:
{
  sops.secrets."savarcast-passwd-root".neededForUsers = true;
  users.users = {
    root = {
      hashedPasswordFile = config.sops.secrets."savarcast-passwd-root".path;
      openssh.authorizedKeys.keys = [
        # l33tname (bgt-comments-nixos.pub)
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjLMILyxqNEleJqdoJbf/BObcjVVTH8XZ2Vv0B8qtnl hi@l33t.name"
        # ingo
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6Ge3TFE5CfSjihhSjq5cGiT/CjPHuTS9rX8vxS/LAoo3MGz0ZmjOvwzDm/1zQjpWuJC4JFBdJiRISrEb6yO9h+lBGIzRI0bbWOlpeDiyxGYnifBB2SlcFHDOKNzm1FSbXBz0IOg/FiPGjdTOwmrQjV6q9DgVe5ZrLmVeEHNKnUI1q4kH7u0jSW3wIpQH82FilY709qauAzxDohqpc0UGT7cy+2ZZTKu+CEOziUNNrCV2/rLdnynBGeqYnk5o73ml6yIUx9RFFtB+VSSSAoPVHNtr0v9/Jla/moC6Fh6WDxtPQuVbNPB/f7l2AuUbNKKp0BTOpxZlAhWd29LR6LSSDOFZTcVLE60kxTwNxCpQWSssf6/yf1m86O43zPGGecgYEprnmL5FI9JN2Z8IqPx6RFy0heKZpgES/wcCeURlqU6zIJqQ2KSeiS/YbMaJd40lh3UtFf1tkjKUyHny5D04B6WcK1Ke3soCArSY9GYj9IwrqfDSD5RuBZ7frat7SuxY6klwR3GpBIBkm8MgzXhdktazBlNDRmG1FQtjkPX6Tza75CvMYkQiil9g1R+5BqL7KDLaULGEWkt5HIyq2W6NFjDFOgqYHqIUVx9G2f5bALA88nLsATBUPcrNvwoskQohbIct9uTK00NcQaQ2CGd7uhUZv5lXpLtIWYGxh/92bOw=="
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEA5G4SzPWZAJHrxpN2hQ0TzfPz5KO4eZISZxL3j/pkPs+6/YLXwB22AuU5qvNBi5uVIIZNqJBoaAcj/NePkiu6i2iAVzntAVWhBQlCLIlN0YXwXZ7E19fVUxvG65XV8D86YXSKrKkeDqk6SmQhReeWexMxTIKtj9Ipa7i9lPHBsls="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqe0NMgRfP/l5QPhbaoYvam01a4/MX/C4BQJRnDyppK markus@DroopyDog"
      ];
    };
  };
}
