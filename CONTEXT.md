# Hachimi Race Helper

A localization-dictionary generator for Uma Musume (ウマ娘). It takes a hand-curated
watchlist of skill names and produces a `text_data_dict.json` that the Hachimi mod loads,
so that skills the player cares about stand out in-game by colour and by a number.

## Language

### The watchlist

**Watchlist**:
The player's hand-curated set of skill names they want highlighted in-game, one per line,
in the order they should be numbered. Lives in `skill.txt`.
_Avoid_: skill list, skill file

**Preset**:
A saved Watchlist for one particular build or running style, kept in `backups/` as
`skill.<name>.txt` alongside the dictionary it produced. `skill.txt` is always a working
copy of whichever Preset is currently active; it is not itself canonical.
_Avoid_: profile, config

**Tier**:
The priority a Watchlist entry is given, encoded as a leading marker and rendered as a
colour on the skill's name. Three exist: `!` pink (essential), `*` orange (situational),
and no marker at all for blue (normal). Tier expresses *how much the player wants the
skill*, never what kind of skill it is.
_Avoid_: colour, priority, rank

**Index**:
An entry's 1-based position in the Watchlist. It is prefixed to the displayed name in-game,
so line order in `skill.txt` is player-visible and reordering the file renumbers everything.
_Avoid_: line number, position

### Game data

**Skill**:
A named ability an uma can learn, stored under `text_data` category 47. Name grades are
distinguished by a trailing `○` / `◎` / `×`; a Watchlist entry written with `○` matches both
`○` and `◎` but never `×`.

**Factor**:
An inherited stat or skill bonus (因子), stored under category 147, with a ★ rank baked into
its text. A Factor shares its name with the Skill it grants, so one Watchlist entry colours
both.
_Avoid_: inheritance, spark

**Green skill**:
The game's own name for a passive, conditional Skill such as `左回り○` or `秋ウマ娘○`, shown
with a green icon in-game. It is a *category of skill*, deliberately not a Tier — the colour
axis in this project stays reserved for priority, so a Green skill gets whatever Tier the
player assigns it like any other.
_Avoid_: passive skill, conditional skill

**Phase prefix**:
`[E]` / `[M]` / `[L]`, prepended to a Skill's displayed name to say when in a race it fires.
Derived automatically from the Skill's own trigger conditions in `master.mdb`, never from
the Watchlist.
_Avoid_: timing tag, activation marker

### Sources

**Game database**:
`master.mdb`, the authoritative source of Skill and Factor names. The copy in this repo is a
snapshot and goes stale as the game patches; it is refreshed from the player's own install at
`UmamusumePrettyDerby_Jpn_Data/Persistent/master/master.mdb`. A Watchlist entry that lands in
`missing_skills.log` usually means the snapshot is old, not that the name is wrong.
_Avoid_: mdb, master db

**Replace Mode**:
The build overwrites categories 47, 48 and 147 outright rather than merging into the English
base, so only Watchlist entries carry an English name and every other Skill stays Japanese.
This is deliberate, not a regression: the untranslated majority is the background the
Watchlist stands out against. A cat47 count in the tens rather than the thousands is the
expected result.
_Avoid_: merge, overlay, patch

**Translation source**:
The `hachimi-tl-en` and `hachimi-sd` submodules, which supply the English base dictionary and
the skill-description text respectively. The build replaces categories 47, 48 and 147 in the
English base and leaves every other category untouched.
_Avoid_: TL repo, upstream
