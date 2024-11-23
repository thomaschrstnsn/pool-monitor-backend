{ pkgs, lib, config, inputs, ... }:

let
  database = {
    name = "pool_monitor";
    host = "localhost";
    port = 5432;
    user = "pool_monitor";
    password = "secret_pool_admin_password";
  };
  grafana = {
    port = 3210;
  };
in
{
  dotenv.enable = true;

  env.DATABASE_USER = database.user;
  env.DATABASE_PASS = database.password;
  env.DATABASE_HOST = database.host;
  env.DATABASE_PORT = database.port;
  env.DATABASE_NAME = database.name;

  env.RUST_LOG = "info";

  # https://devenv.sh/packages/
  packages = with pkgs;  (lib.optionals
    stdenv.isDarwin
    (with darwin.apple_sdk; [
      frameworks.SystemConfiguration
    ])
  ++ [ git bacon ]);

  scripts.pm-graf-dev.exec = ''
    cd $DEVENV_ROOT/grafana
    set -ex
    docker build --build-arg DATABASE_HOST=host.docker.internal -t pm-graf:dev .
    docker run \
      -p ${toString grafana.port}:3000 \
      -e DATABASE_USER=${database.user} \
      -e DATABASE_PASS=${database.password} \
      -e DATABASE_HOST=host.docker.internal \
      -e DATABASE_PORT=${toString database.port} \
      -e DATABASE_NAME=${database.name} \
      pm-graf:dev
  '';

  scripts.pm-db-backup.exec = ''
    set -ex
    FILENAME="$DEVENV_ROOT/pool_monitor-$(date -Iminutes).bck"
    pg_dump -U pool_monitor pool_monitor > $FILENAME
  '';

  scripts.pm-db-restore.exec = ''
    set -ex
    echo restoring from: '$1'
    psql -U pool_monitor -d pool_monitor < $1
  '';

  # https://devenv.sh/scripts/
  # banner source: https://patorjk.com/software/taag/#p=display&f=Tmplr&t=Pool%0AMonitor
  enterShell = ''
    cat .banner
    echo ""
    echo ✅ DATABASE_USER:$DATABASE_USER
    echo ✅ DATABASE_PASS:$DATABASE_PASS
    echo ✅ DATABASE_HOST:$DATABASE_HOST
    echo ✅ DATABASE_PORT:$DATABASE_PORT
    echo ✅ DATABASE_NAME:$DATABASE_NAME
    echo
    echo "(when started with pm-graf-dev): http://localhost:${toString grafana.port}"
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
      CREATE USER ${database.user} WITH PASSWORD '${database.password}';
      CREATE DATABASE ${database.name} OWNER ${database.user};'';
  };

  # https://devenv.sh/languages/
  languages.rust = {
    enable = true;
    channel = "stable";
  };

  # See full reference at https://devenv.sh/reference/options/
}
