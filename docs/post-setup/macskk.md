# macSKK Setup (macOS)

macOS SKK input is managed with macSKK, configured to feel close to CorvusSKK.

## Managed Files

- `~/.config/homebrew/Brewfile.common` (`cask "mtgto/macskk/macskk"`)
- `~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Library/Preferences/net.mtgto.inputmethod.macSKK.plist`
- `~/.config/karabiner/karabiner.json`
- `~/.chezmoiscripts/run_after_onchange_client_darwin_212-macskk.sh.tmpl`

## CorvusSKK Mapping

- Candidate count: `7` (`inlineCandidateCount`)
- Candidate keys: `ASDFGHJKL` (`selectCandidateKeys`)
- Annotation: enabled (`showAnnotation=true`)
- Dynamic completion: disabled (`showCompletion=false`)
- Show candidate list for completion: enabled (`showCandidateForCompletion=true`)
- Completion from all dictionaries: enabled (`findCompletionFromAllDicts=true`)
- Private mode default: off (`privateMode=false`)
- Input mode panel: enabled (`showInputModePanel=true`)
- Key bindings: managed via `keyBindingSets` (includes `l -> abbrev`)

## Keyboard Behavior

- `Space`: tap = Space, hold = Shift (SandS)
- `CapsLock`: remapped to `Left Ctrl`
- `Left Shift` tap: switch to macSKK hiragana (`net.mtgto.inputmethod.macSKK.hiragana`)
- `Right Shift` tap: profile dependent
  - Profile A: macSKK ASCII (`net.mtgto.inputmethod.macSKK.ascii`)
  - Profile B: macOS `ABC` (`com.apple.keylayout.ABC`)
- `Shift+...` works as a normal modifier (input source changes only on tap)
- Input switch is done by Karabiner `select_input_source` (avoid sending app-visible `Ctrl+...` shortcuts)
- `l` enters direct mode and `/` enters abbrev mode (`keyBindingSets` managed)

### Shift IME Pattern Switch (Karabiner GUI)

Use Karabiner-Elements profile switch in GUI:

- `Default profile (RShift -> macSKK ASCII)` (recommended for stability)
- `Default profile (RShift -> macOS ABC)` (when explicit macOS alnum is needed)

## Shortcut Collision Note

If left/right shift tap is implemented by sending `Ctrl+Shift+J/L`, app shortcuts may collide (for example terminal/agent tools).

Current config avoids this by switching input source directly in Karabiner:

- Left Shift tap: `select_input_source.input_mode_id=net.mtgto.inputmethod.macSKK.hiragana`
- Right Shift tap (Profile A): `select_input_source.input_mode_id=net.mtgto.inputmethod.macSKK.ascii`
- Right Shift tap (Profile B): `select_input_source.input_source_id=com.apple.keylayout.ABC`

If Profile B is used, ensure `ABC` is enabled in macOS input sources.

## Notes

- `showInputModePanel`:
  - `true`: shows a small mode panel on mode switch (e.g. hiragana / ASCII)
  - `false`: hides the mode panel

## Dictionary Setup

The post-change script ensures:

- `~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/skk-jisyo.utf8` exists
- `SKK-JISYO.L` is downloaded/updated from `skk-dev/dict` when missing or older than 30 days
- `SKK-JISYO.jinmei` is downloaded/updated from `skk-dev/dict` when missing or older than 30 days

## Apply and Verify

```bash
chezmoi apply
```

Then open macSKK settings once and confirm:

- Candidate keys are `ASDFGHJKL`
- Candidate count is `7`
