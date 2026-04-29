#!/bin/bash

# 1. Configuration
MASTER_FILE="hachimi-tl-en/localized_data/text_data_dict.json"
RUNNER_LIST="skill.txt"
FACTOR_FILE_BR="Assets/GameData/ja-JP/factor_ids.br"
SKILL_FILE_BR="Assets/GameData/ja-JP/skill_data.br"
SD_FILE="hachimi-sd/localized_data/text_data_dict.json"
OUTPUT_FILE="text_data_dict.json"

# 2. Dependencies & Files Check
if ! command -v brotli &> /dev/null; then
    echo "❌ Error: 'brotli' is not installed."
    exit 1
fi

if [[ ! -f "$MASTER_FILE" || ! -f "$RUNNER_LIST" || ! -f "$SD_FILE" ]]; then
    echo "❌ Error: Missing required files."
    exit 1
fi

echo "🚀 Starting Hachimi-Edge Localization Pipeline (Dual-Color Edition)..."

# 3. Handle Temporary Files & Decompress Brotli
TEMP_DIR=$(mktemp -d)
FACTOR_JSON="$TEMP_DIR/factor_ids.json"
SKILL_JSON="$TEMP_DIR/skill_data.json"

echo "🔓 Decompressing .br assets..."
brotli -dc "$FACTOR_FILE_BR" > "$FACTOR_JSON"
brotli -dc "$SKILL_FILE_BR" > "$SKILL_JSON"

# 4. Smart Regex Generation (แยก 2 กลุ่ม)
echo "🔍 Extracting priorities from skill.txt..."

# กลุ่มที่ 1: สำคัญมาก (มี ! นำหน้า) -> แปลง ○◎ เป็น [○◎]
HIGH_PRIORITY=$(grep "^!" "$RUNNER_LIST" | sed 's/^!//' | sed -E 's/(.*)[○◎]/\1[○◎]/' | paste -sd "|" -)

# กลุ่มที่ 2: ทั่วไป (ไม่มี ! นำหน้า) -> แปลง ○◎ เป็น [○◎]
NORMAL_PRIORITY=$(grep -v "^!" "$RUNNER_LIST" | grep -vE "^#|^$" | sed -E 's/(.*)[○◎]/\1[○◎]/' | paste -sd "|" -)

# 5. Process Category 47 (Skills - Direct ID)
echo "📦 Building category 47 with Smart Colors..."
cat "$SKILL_JSON" | jq -r --arg high "$HIGH_PRIORITY" --arg normal "$NORMAL_PRIORITY" '
    [ .[] | 
      if ($high != "" and (.Name | test($high))) then
        { (.Id | tostring): ("<color=#ff0066>" + .Name + "</color>") }
      elif ($normal != "" and (.Name | test($normal))) then
        { (.Id | tostring): ("<color=#0055ff>" + .Name + "</color>") }
      else empty end
    ] | add' > "$TEMP_DIR/47.json"

# 6. Process Category 147 (Factors - Cleaned & Smart Colors)
echo "📦 Building category 147 with Smart Colors..."
cat "$FACTOR_JSON" | jq -r --arg high "$HIGH_PRIORITY" --arg normal "$NORMAL_PRIORITY" '
    to_entries | 
    map(
      . as $item | ($item.value | gsub("[★☆]"; "")) as $n |
      if ($high != "" and ($n | test($high))) then
        { ($item.key): ("<color=#ff0066>" + $n + "</color>") }
      elif ($normal != "" and ($n | test($normal))) then
        { ($item.key): ("<color=#0055ff>" + $n + "</color>") }
      else empty end
    ) | add' > "$TEMP_DIR/147.json"

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

# 9. Cleanup
rm -rf "$TEMP_DIR"

echo "✨ Success! Runner dictionary with dual-priority colors created: $OUTPUT_FILE"
