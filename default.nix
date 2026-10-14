{
  config,
  pkgs,
  lib,
  ...
}:

let
  user = config.common.username;
  cfg = config.services.beets;
  beetsConfig = pkgs.writeText "beets-config.yaml" ''
    directory: ${cfg.libraryPath}
    threaded: yes
    original_date: yes
    import:
        write: yes
        copy: yes
        move: no
        log: ${cfg.libraryPath}/.beets/import.log
    plugins:
        - musicbrainz
        - discogs
        - fetchart
        - embedart
        - hook
        - edit
    art_filename: max_cover
    embedart:
        auto: yes
    fetchart:
        deinterlace: yes
        cover_format: JPEG
    paths:
        default: $albumartist/$year - $album%aunique{}/$track - $title
        singleton: Non-Album/$artist/$year - $title
        comp: Compilations/$year - $album%aunique{}/$track - $title
    hook:
        hooks:
            - event: album_imported
              command: 'magick "{album.path}/max_cover.jpg" -resize 200x200^ -gravity center -extent 200x200 -interlace none "{album.path}/cover.jpg"'
  '';
in
{
  options.services.beets = {
    enable = lib.mkEnableOption "beets music library";
    libraryPath = lib.mkOption {
      type = lib.types.str;
      default = "/away/main/Music";
      description = "Root directory for the beets library.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.downloads = { };

    environment.systemPackages = [
      pkgs.beets
      pkgs.imagemagick
    ];

    environment.variables.BEETSDIR = "${cfg.libraryPath}/.beets/";

    systemd.tmpfiles.rules = [
      "d ${cfg.libraryPath}/.beets 0755 ${user} downloads -"
      "L+ ${cfg.libraryPath}/.beets/config.yaml - - - - ${beetsConfig}"
    ];
  };
}
