# Replace categories 47/48/147 instead of merging into the English base

The point of this tool is to make the handful of skills the player is shopping for easy to
spot in a long in-game list, so the build **replaces** categories 47, 48 and 147 outright
(`build_dict.sh`, "Final Assembly") rather than merging its entries into the upstream English
dictionary. Only Watchlist entries get an English name, a number and a colour; every other
skill stays Japanese, and that untranslated majority is exactly what the Watchlist stands out
against. Translating everything would restore ~1800 skill names but destroy the contrast that
makes selection fast.

## Considered Options

- **Replace** (chosen) — `.["47"] = ($d47[0] // {})`. Watchlist pops against Japanese noise.
- **Merge** — `.["47"] += ($d47[0] // {})`. Keeps the full English translation *and* the
  colours. Rejected: with every name in English and readable, the coloured ones no longer
  jump out, which is the whole feature.

## Consequences

- A generated `text_data_dict.json` has a category-47 count in the **tens**, not the
  thousands. This looks like a bug and is not one. Do not "fix" it.
- Reverting to merge is a one-character edit but changes what the tool is for — treat it as a
  product decision, not a cleanup.
- The player must be able to read enough Japanese to navigate the rest of the game. That is an
  accepted constraint, not an oversight.
