{ pkgs, lib, config, inputs, ... }:

let
  database_user = "pool_monitor";
  database_password = "secret_pool_admin_password";
in
{
  dotenv.enable = true;
  env.DATABASE_URL = "postgres://${database_user}:${database_password}@localhost/pool_monitor";


  # https://devenv.sh/packages/
  packages = (lib.optionals
    pkgs.stdenv.isDarwin
    (with pkgs.darwin.apple_sdk; [
      frameworks.SystemConfiguration
    ])
  ++ [ pkgs.git ]);


  # https://devenv.sh/scripts/
  # banner source: https://patorjk.com/software/taag/#p=display&f=Impossible&t=Pool%0AMonitor
  enterShell = ''
    echo "         _          _            _            _                                             "
    echo "        /\ \       /\ \         /\ \         _\ \                                           "
    echo "       /  \ \     /  \ \       /  \ \       /\__ \                                          "
    echo "      / /\ \ \   / /\ \ \     / /\ \ \     / /_ \_\                                         "
    echo "     / / /\ \_\ / / /\ \ \   / / /\ \ \   / / /\/_/                                         "
    echo "    / / /_/ / // / /  \ \_\ / / /  \ \_\ / / /                                              "
    echo "   / / /__\/ // / /   / / // / /   / / // / /                                               "
    echo "  / / /_____// / /   / / // / /   / / // / / ____                                           "
    echo " / / /      / / /___/ / // / /___/ / // /_/_/ ___/\                                         "
    echo "/ / /      / / /____\/ // / /____\/ //_______/\__\/                                         "
    echo "\/_/       \/_________/ \/_________/ \_______\/                                             "
    echo "        _   _         _            _              _        _            _            _      "
    echo "       /\_\/\_\ _    /\ \         /\ \     _     /\ \     /\ \         /\ \         /\ \    "
    echo "      / / / / //\_\ /  \ \       /  \ \   /\_\   \ \ \    \_\ \       /  \ \       /  \ \   "
    echo "     /\ \/ \ \/ / // /\ \ \     / /\ \ \_/ / /   /\ \_\   /\__ \     / /\ \ \     / /\ \ \  "
    echo "    /  \____\__/ // / /\ \ \   / / /\ \___/ /   / /\/_/  / /_ \ \   / / /\ \ \   / / /\ \_\ "
    echo "   / /\/________// / /  \ \_\ / / /  \/____/   / / /    / / /\ \ \ / / /  \ \_\ / / /_/ / / "
    echo "  / / /\/_// / // / /   / / // / /    / / /   / / /    / / /  \/_// / /   / / // / /__\/ /  "
    echo " / / /    / / // / /   / / // / /    / / /   / / /    / / /      / / /   / / // / /_____/   "
    echo "/ / /    / / // / /___/ / // / /    / / /___/ / /__  / / /      / / /___/ / // / /\ \ \     "
    echo "\/_/    / / // / /____\/ // / /    / / //\__\/_/___\/_/ /      / / /____\/ // / /  \ \ \    "
    echo "        \/_/ \/_________/ \/_/     \/_/ \/_________/\_\/       \/_________/ \/_/    \_\/    "
    echo ""
    echo ✅ DATABASE_URL=$DATABASE_URL
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
