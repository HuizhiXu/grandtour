# Runtime font sources

Every font file in this directory tree is an SIL Open Font License 1.1 font,
subset to WOFF2. Its license is the `<Family>-OFL.txt` file beside it; keep the
two together when copying, renaming or redistributing a font. Web exports list
these files on their Open Source Licenses page.

Noto Sans SC (`NotoSansSC-VF.subset.woff2`, variable weight) supplies the
common Simplified Chinese glyph fallback after the template's body font. Its
hash and size are in `assets.lock.json` and `runtime-cjk.json`. It covers the
shared common repertoire, including player input, rather than only current UI
copy. Rare characters outside that repertoire remain unsupported.

Use `python3 tools/install_cjk_font.py --check` to verify the pinned runtime
font and its license. Loader fonts are separate lightweight subsets of the same
approved family. Runtime imports disable system fallback; web exports bundle the font.

`NotoSans-Vietnamese.subset.woff2` adds Vietnamese extended vowels (including
`ế` and `ụ` in `Ngô Viết Thụ`) and combining accents after the existing Chinese
fallback. The regular/medium/bold resources select matching weights. This is
bundled with `NotoSans-OFL.txt`, without relying on installed system fonts.
Source: Google Fonts' official `ofl/notosans/NotoSans[wdth,wght].ttf` (Noto Sans
2.015). Source/output hashes and coverage are recorded in
`NotoSans-Vietnamese.subset.json`; rebuild with
`python3 tools/prepare_vietnamese_font.py --source /path/to/NotoSans.ttf`.
