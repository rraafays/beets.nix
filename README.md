# beets

Beets music library layout, config, and `BEETSDIR` for `config.common.username`.

NixOS only. Requires `./common`. Import `./src/beets` to activate; defines the `downloads` group alongside `transmission` / `slskd` when those are imported. Override `services.beets.libraryPath` on the host if needed.
