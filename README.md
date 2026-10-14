# beets

Beets music library layout, config, and `BEETSDIR` for `config.common.username`.

NixOS only. Requires `./common`. Expects a `downloads` Unix group (see `slskd.nix`). Override `services.beets.libraryPath` on the host if needed.
