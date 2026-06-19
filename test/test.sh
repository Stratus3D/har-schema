#!/usr/bin/env sh

# Unofficial Bash "strict mode"
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo
IFS=$'\t\n' # Stricter IFS settings

DIR="$(dirname "$0")"
SCHEMA="$DIR/../har-schema.json"
META_SCHEMA="$DIR/json-schema.json"
PASS=0
FAIL=0

check() {
    label="$1"
    schemafile="$2"
    file="$3"
    expected="$4"

    check-jsonschema --schemafile "$schemafile" "$file" > /dev/null 2>&1 && actual=0 || actual=1

    if [ "$actual" -eq "$expected" ]; then
        echo "PASS ($label) $file"
        PASS=$((PASS + 1))
    else
        echo "FAIL ($label) $file"
        FAIL=$((FAIL + 1))
    fi
}

check "meta" "$META_SCHEMA" "$SCHEMA" 0

for file in "$DIR"/valid/*.har.json; do
    check "valid" "$SCHEMA" "$file" 0
done

for file in "$DIR"/invalid/*.har.json; do
    check "invalid" "$SCHEMA" "$file" 1
done

echo "Results: $PASS passed, $FAIL failed"

[ "$FAIL" -eq 0 ]
