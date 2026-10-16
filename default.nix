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
    edit:
        albumfields: album albumartist
        itemfields: track title artist album
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

  beetEditAlbum = pkgs.writeShellScriptBin "beet-edit-album" ''
    exec ${pkgs.beets}/bin/beet edit -a "$@"
  '';

  beetSetAlbumartist = pkgs.writeShellScriptBin "beet-set-albumartist" ''
    if [ "$#" -lt 2 ]; then
      echo "usage: beet-set-albumartist QUERY ALBUMARTIST" >&2
      echo "example: beet-set-albumartist 'album:Abbey Road' 'The Beatles'" >&2
      exit 1
    fi
    exec ${pkgs.beets}/bin/beet modify -a "$1" albumartist="$2"
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
    editor = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = ''
        Command used for VISUAL and EDITOR when running beet edit (including albumartist via beet edit -a).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.downloads = { };

    environment.systemPackages = [
      pkgs.beets
      pkgs.imagemagick
      beetEditAlbum
      beetSetAlbumartist
    ];

    environment.variables = {
      BEETSDIR = "${cfg.libraryPath}/.beets/";
      EDITOR = cfg.editor;
      VISUAL = cfg.editor;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.libraryPath}/.beets 0755 ${user} downloads -"
      "L+ ${cfg.libraryPath}/.beets/config.yaml - - - - ${beetsConfig}"
    ];
  };
}
