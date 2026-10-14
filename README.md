# beets

Beets music library layout, config, and `BEETSDIR` for `config.common.username`.

NixOS only. Requires `./common`. Defines the `downloads` group when enabled, or use it alongside `transmission.nix` / `slskd.nix`. Override `services.beets.libraryPath` on the host if needed.
