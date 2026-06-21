# Graph Report - hachimi-race-helper  (2026-05-08)

## Corpus Check
- 5 files · ~13,498,113 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 28 nodes · 23 edges · 7 communities (5 shown, 2 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]

## God Nodes (most connected - your core abstractions)
1. `Hachimi Race Helper (ウマ娘 Skill Visualizer)` - 6 edges
2. `🛠️ Installation` - 3 edges
3. `ls_tree()` - 2 edges
4. `main()` - 2 edges
5. `🎨 Skill Color Classification (Colors)` - 2 edges
6. `🚀 How to Use` - 2 edges
7. `📸 Demo Screenshots` - 1 edges
8. `🏷️ Prefixes (Skill Activation Timing)` - 1 edges
9. `⚙️ How to Define Colors` - 1 edges
10. `Dependencies:` - 1 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (7 total, 2 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.22
Nodes (8): Contributing translations, Data usage, Install / Use, Philosophy, Translation sources, Umamusume English Translations, Updating, Versions

### Community 1 - "Community 1"
Cohesion: 0.25
Nodes (7): code:bash (./build_dict.sh), 📸 Demo Screenshots, Hachimi Race Helper (ウマ娘 Skill Visualizer), ⚙️ How to Define Colors, 🚀 How to Use, 🏷️ Prefixes (Skill Activation Timing), 🎨 Skill Color Classification (Colors)

### Community 3 - "Community 3"
Cohesion: 0.67
Nodes (3): Dependencies:, Error Checking (`missing_skills.log`), 🛠️ Installation

## Knowledge Gaps
- **16 isolated node(s):** `📸 Demo Screenshots`, `🏷️ Prefixes (Skill Activation Timing)`, `⚙️ How to Define Colors`, `Dependencies:`, `Error Checking (`missing_skills.log`)` (+11 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Hachimi Race Helper (ウマ娘 Skill Visualizer)` connect `Community 1` to `Community 3`?**
  _High betweenness centrality (0.114) - this node is a cross-community bridge._
- **Why does `🛠️ Installation` connect `Community 3` to `Community 1`?**
  _High betweenness centrality (0.048) - this node is a cross-community bridge._
- **What connects `📸 Demo Screenshots`, `🏷️ Prefixes (Skill Activation Timing)`, `⚙️ How to Define Colors` to the rest of the system?**
  _16 weakly-connected nodes found - possible documentation gaps or missing edges._