{ pkgs, lib, config, inputs, ... }:

let
  database_user = "pool_monitor";
  database_password = "secret_pool_admin_password";
in
{
  dotenv.enable = true;
  devenv.warnOnNewVersion = false;

  env.DATABASE_URL = "postgres://${database_user}:${database_password}@localhost/pool_monitor";


  # https://devenv.sh/packages/
  packages = with pkgs;  (lib.optionals
    stdenv.isDarwin
    (with darwin.apple_sdk; [
      frameworks.SystemConfiguration
    ])
  ++ [ git bacon ]);


  # https://devenv.sh/scripts/
  # banner source: https://patorjk.com/software/taag/#p=display&f=Tmplr&t=Pool%0AMonitor
  enterShell = ''
    /bin/cat .banner
    echo ""
    echo ✅ DATABASE_URL=$DATABASE_URL
    echo ""
    echo ""
  '';

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep "2.42.0"
  '';

  # https://devenv.sh/services/
  services.postgres = {
    enable = true;
    listen_addresses = "0.0.0.0";
    initialScript = ''
      CREATE USER ${database_user} WITH PASSWORD '${database_password}';
      CREATE DATABASE pool_monitor OWNER ${database_user};'';
  };

  # https://devenv.sh/languages/
  languages.rust.enable = true;

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
