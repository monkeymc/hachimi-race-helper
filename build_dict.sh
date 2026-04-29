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
JSON_47=$(cat "$SKILL_JSON" | jq -r --arg high "$HIGH_PRIORITY" --arg normal "$NORMAL_PRIORITY" '
    [ .[] | 
      if ($high != "" and (.Name | test($high))) then
        { (.Id | tostring): ("<color=#ff0066>" + .Name + "</color>") }
      elif ($normal != "" and (.Name | test($normal))) then
        { (.Id | tostring): ("<color=#0055ff>" + .Name + "</color>") }
      else empty end
    ] | add')

# 6. Process Category 147 (Factors - Cleaned & Smart Colors)
echo "📦 Building category 147 with Smart Colors..."
JSON_147=$(cat "$FACTOR_JSON" | jq -r --arg high "$HIGH_PRIORITY" --arg normal "$NORMAL_PRIORITY" '
    to_entries | 
    map(
      . as $item | ($item.value | gsub("[★☆]"; "")) as $n |
      if ($high != "" and ($n | test($high))) then
        { ($item.key): ("<color=#ff0066>" + $n + "</color>") }
      elif ($normal != "" and ($n | test($normal))) then
        { ($item.key): ("<color=#0055ff>" + $n + "</color>") }
      else empty end
    ) | add')

# 7. Process Category 48 (SD Data)
echo "📦 Syncing category 48 from SD file..."
JSON_48=$(jq -c '.["48"]' "$SD_FILE")

# 8. Final Assembly (Replace Mode)
echo "🛠️ Final Assembly: Replacing categories 47, 48, 147..."
jq --argjson d47 "$JSON_47" \
   --argjson d48 "$JSON_48" \
   --argjson d147 "$JSON_147" \
   '.["47"] = $d47 | .["48"] = $d48 | .["147"] = $d147' \
   "$MASTER_FILE" > "$OUTPUT_FILE"

# 9. Cleanup
rm -rf "$TEMP_DIR"

echo "✨ Success! Runner dictionary with dual-priority colors created: $OUTPUT_FILE"
