#!/bin/bash

# 1. Configuration
MASTER_FILE="hachimi-tl-en/localized_data/text_data_dict.json"
SKILL_LIST="skill.txt"
MASTER_MDB="master.mdb"
SD_FILE="hachimi-sd/localized_data/text_data_dict.json"
OUTPUT_FILE="text_data_dict.json"

# 2. Dependencies & Files Check
if ! command -v sqlite3 &> /dev/null; then
    echo "❌ Error: 'sqlite3' is not installed."
    exit 1
fi

if [[ ! -f "$MASTER_FILE" || ! -f "$SKILL_LIST" || ! -f "$SD_FILE" || ! -f "$MASTER_MDB" ]]; then
    echo "❌ Error: Missing required files."
    exit 1
fi

echo "🚀 Starting Hachimi-Edge Localization Pipeline (Dual-Color Edition)..."

# 3. Handle Temporary Files & Extract JSON from SQLite
TEMP_DIR=$(mktemp -d)
FACTOR_JSON="$TEMP_DIR/factor_ids.json"
SKILL_JSON="$TEMP_DIR/skill_data.json"

echo "🔓 Extracting data from master.mdb..."
sqlite3 -json "$MASTER_MDB" "SELECT [index], text AS Name FROM text_data WHERE category = 147;" > "$FACTOR_JSON"
sqlite3 -json "$MASTER_MDB" 'SELECT s.id AS "index", n.text AS Name, s.precondition_1, s.condition_1, s.precondition_2, s.condition_2 FROM skill_data s JOIN text_data n ON s.id = n."index" AND n.category = 47;' > "$SKILL_JSON"

# 4. Smart Regex Generation (แยก 2 กลุ่ม)
echo "🔍 Extracting priorities from skill.txt..."
CLEAN_SKILL="$TEMP_DIR/clean_skill.txt"
tr -d '\r' < "$SKILL_LIST" > "$CLEAN_SKILL"

# กลุ่มที่ 1: สำคัญมาก (มี ! นำหน้า) -> แปลง ○◎ เป็น [○◎]
HIGH_PRIORITY=$(grep "^!" "$CLEAN_SKILL" | sed 's/^!//' | sed -E 's/(.*)[○◎]/\1[○◎]/' | paste -sd "|" -)

# กลุ่มที่ 2: ทั่วไป (ไม่มี ! นำหน้า) -> แปลง ○◎ เป็น [○◎]
NORMAL_PRIORITY=$(grep -v "^!" "$CLEAN_SKILL" | grep -vE "^#|^$" | sed -E 's/(.*)[○◎]/\1[○◎]/' | paste -sd "|" -)

# 5. Process Category 47 (Skills - Direct ID)
echo "📦 Building category 47 with Smart Colors..."
cat "$SKILL_JSON" | jq -r --arg high "$HIGH_PRIORITY" --arg normal "$NORMAL_PRIORITY" '
    [ .[] | 
      ((.precondition_1 // "") + "|" + (.condition_1 // "") + "|" + (.precondition_2 // "") + "|" + (.condition_2 // "")) as $c |
      (if ($c | test("phase.*==[23]|phase>=2|is_lastspurt==1|is_finalcorner")) then "[L] "
       elif ($c | test("phase.*==1|distance_rate>=50|later_half")) then "[M] "
       elif ($c | test("phase.*==0")) then "[E] "
       else "" end) as $prefix |
      ($prefix + .Name) as $final_name |
      if ($high != "" and (.Name | test($high))) then
        { (.index | tostring): ("<color=#ff0066>" + $final_name + "</color>") }
      elif ($normal != "" and (.Name | test($normal))) then
        { (.index | tostring): ("<color=#0055ff>" + $final_name + "</color>") }
      else empty end
    ] | add' > "$TEMP_DIR/47.json"

# 6. Process Category 147 (Factors - Cleaned & Smart Colors)
echo "📦 Building category 147 with Smart Colors..."
cat "$FACTOR_JSON" | jq -r --arg high "$HIGH_PRIORITY" --arg normal "$NORMAL_PRIORITY" '
    [ .[] | 
      (.Name | gsub("[★☆]"; "")) as $n |
      if ($high != "" and ($n | test($high))) then
        { (.index | tostring): ("<color=#ff0066>" + $n + "</color>") }
      elif ($normal != "" and ($n | test($normal))) then
        { (.index | tostring): ("<color=#0055ff>" + $n + "</color>") }
      else empty end
    ] | add' > "$TEMP_DIR/147.json"

# 7. Process Category 48 (SD Data)
echo "📦 Syncing category 48 from SD file..."
jq -c '.["48"]' "$SD_FILE" > "$TEMP_DIR/48.json"

# 8. Final Assembly (Replace Mode)
echo "🛠️ Final Assembly: Replacing categories 47, 48, 147..."
jq --slurpfile d47 "$TEMP_DIR/47.json" \
   --slurpfile d48 "$TEMP_DIR/48.json" \
   --slurpfile d147 "$TEMP_DIR/147.json" \
   '.["47"] = ($d47[0] // {}) | .["48"] = ($d48[0] // {}) | .["147"] = ($d147[0] // {})' \
   "$MASTER_FILE" > "$OUTPUT_FILE"

# 9. Analysis Log
echo "📝 Generating analysis log (missing_skills.log)..."
LOG_FILE="missing_skills.log"
echo "=== Skills/Factors Analysis Log ===" > "$LOG_FILE"
echo "Generated at: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Extract all names found (strip color tags)
jq -r 'to_entries[] | .value' "$TEMP_DIR/47.json" "$TEMP_DIR/147.json" 2>/dev/null | sed -E 's/<[^>]*>//g' > "$TEMP_DIR/all_found.txt"

echo "=== Items in skill.txt NOT FOUND in game data ===" >> "$LOG_FILE"
cat "$CLEAN_SKILL" | grep -vE "^#|^$" | sed 's/^!//' | while read -r item; do
    item_regex=$(echo "$item" | sed -E 's/(.*)[○◎]/\1[○◎]/')
    if ! grep -qE "${item_regex}" "$TEMP_DIR/all_found.txt"; then
        echo "- $item" >> "$LOG_FILE"
    fi
done

echo "" >> "$LOG_FILE"
echo "=== Raw Regex Patterns Used ===" >> "$LOG_FILE"
echo "HIGH_PRIORITY: $HIGH_PRIORITY" >> "$LOG_FILE"
echo "NORMAL_PRIORITY: $NORMAL_PRIORITY" >> "$LOG_FILE"

# 10. Cleanup
rm -rf "$TEMP_DIR"

echo "✨ Success! Runner dictionary created: $OUTPUT_FILE"
echo "📊 Analysis log saved to: $LOG_FILE"
