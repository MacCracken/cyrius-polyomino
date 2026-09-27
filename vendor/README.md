# vendor/

Third-party single-file snapshots that are **deliberately committed** (unlike
`lib/`, which is the regenerable stdlib snapshot and is gitignored).

## `vani-core.cyr`

- **Source**: [vani](https://github.com/MacCracken/vani) `dist/vani-core.cyr`
  (the `core` profile — the playback-only ALSA PCM shim: the `audio_*` API).
- **Version**: 1.2.5 (pins cyrius 6.6.2; we build on 6.6.6) — byte-identical to
  vani's committed `dist/vani-core.cyr` at tag `1.2.5` (sha256 `28a8c870…`), the
  release the 6.6.6 stdlib bundles as `lib/vani.cyr` (full profile). The
  `audio_*` calls polyomino makes keep their signatures and plain-`i64` returns,
  and `audio_open_playback` still returns 0 on failure; vani 1.2.3's Result
  value-form break touches only the `vani_*` layer, which polyomino never calls.
- **Why vendored instead of a `[deps.vani]` git dependency**: resolving vani
  as a git dep pulls its entire manifest tree (patra ~160 KB, yukti ~211 KB,
  sakshi) into `lib/` and links it — DCE does not prune whole vendored
  modules, so the binary ballooned ~4× (488 KB vs 136 KB). `vani-core.cyr` is
  self-contained (raw ALSA over syscalls, ~800 lines) and needs none of that
  tree, so committing the one file keeps the build lean and reproducible
  without the bloat. Mirrors how cyrius-doom vendors `bsp` as a single file.
- **Consumed by**: `src/audio.cyr` — `audio_open_playback`,
  `audio_set_params_fmt` (explicit `SND_PCM_FORMAT_S16_LE`; vani ≥ 1.2.0),
  `audio_prepare`, `audio_write`, `audio_drain`, `audio_close`, and `audio_fd`
  plus the `SNDRV_PCM_IOCTL_SW_PARAMS` / `AlsaSwParamsLayout` constants for the
  silence-filled sw params (`audio_set_sw_silence` — vani's
  `audio_set_sw_params` pins the silence fields to 0). A refresh must keep
  those names. `include "vendor/vani-core.cyr"` sits before `src/synth.cyr` in
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
