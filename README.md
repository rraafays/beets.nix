# beets

Beets music library layout, config, and `BEETSDIR` for `config.common.username`.

NixOS only. Requires `./common`. Defines the `downloads` group when enabled, or use it alongside `transmission.nix` / `slskd.nix`. Override `services.beets.libraryPath` on the host if needed.

## Album artist

Paths use `$albumartist`. The `edit` plugin is configured with `albumfields: album albumartist` so album artist is editable:

- **During import:** choose `eDit` or `edit Candidates`; change `albumartist` in the YAML header at the top of the buffer.
- **After import:** `beet-edit-album QUERY` (runs `beet edit -a`) or `beet-set-albumartist QUERY 'New Name'` (runs `beet modify -a`).

Album-level changes require `-a` / album mode; the field name is `albumartist`, not `albumartists`.

Set `services.beets.editor` if `$EDITOR` should not be `nvim` (SRVR imports `editor.nix` by default).
