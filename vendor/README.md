# vendor/

Third-party single-file snapshots that are **deliberately committed** (unlike
`lib/`, which is the regenerable stdlib snapshot and is gitignored).

## `vani-core.cyr`

- **Source**: [vani](https://github.com/MacCracken/vani) `dist/vani-core.cyr`
  (the `core` profile — the playback-only ALSA PCM shim: the `audio_*` API).
- **Version**: 0.9.5 (pins cyrius 6.2.1; we build on 6.2.2).
- **Why vendored instead of a `[deps.vani]` git dependency**: resolving vani
  as a git dep pulls its entire manifest tree (patra ~160 KB, yukti ~211 KB,
  sakshi) into `lib/` and links it — DCE does not prune whole vendored
  modules, so the binary ballooned ~4× (488 KB vs 136 KB). `vani-core.cyr` is
  self-contained (raw ALSA over syscalls, ~800 lines) and needs none of that
  tree, so committing the one file keeps the build lean and reproducible
  without the bloat. Mirrors how cyrius-doom vendors `bsp` as a single file.
- **Consumed by**: `src/audio.cyr` (via the `audio_*` symbols);
  `include "vendor/vani-core.cyr"` sits before `src/synth.cyr` in
  `src/main.cyr` and the test suite.

### Refreshing to a newer vani

```sh
# from a checkout/release of vani at the desired tag:
cyrius distlib core          # regenerates dist/vani-core.cyr
cp dist/vani-core.cyr <this-repo>/vendor/vani-core.cyr
# then in this repo: cyrius build + cyrius test must stay green
```

Bump the version note above when you do. Keep it the `core` profile — the
full bundle reintroduces the transitive-dep bloat.
