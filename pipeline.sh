#!/usr/bin/env bash

set -euo pipefail

# NOAA Storm Events Data Pipeline
# Downloads and processes annual storm event records

# Configuration
Year="${1:-2024}"

CREATED_DATE="20260728"
BASE_URL="https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles" 
FILENAME="StormEvents_details-ftp_v1.0_d${Year}_c${CREATED_DATE}.csv.gz"
RAW_DIR="data/raw"
PROCESSED_DIR="data/processed"

#Create directories if they do not exist
mkdir -p "$RAW_DIR" "$PROCESSED_DIR"

echo "Starting NOAA Storm Events Data Pipeline..."
echo "Processing NOAA Storm Events for year: $Year"

# Download NOAA Data
URL="${BASE_URL}/${FILENAME}"
RAW_FILE="${RAW_DIR}/${FILENAME}"

echo "Download URL: $URL"

if [[ ! -f "$RAW_FILE" ]]; then
    echo "Downloading NOAA data..."

    TEMP_FILE="${RAW_FILE}.tmp"

    curl -fL "$URL" -o "$TEMP_FILE"

    mv "$TEMP_FILE" "$RAW_FILE"

else
    echo "File already exists. Skipping."
fi

# Extract compressed CSV
CSV_FILE="${RAW_FILE%.gz}"

if [[ ! -f "${CSV_FILE}" ]]; then
    echo "Extracting CSV..."
    gzip -dc "${RAW_FILE}" > "${CSV_FILE}"
else
    echo "Extracted CSV already exists. Skipping extraction."
fi

# Convert CSV to GeoParquet
PARQUET_FILE="${PROCESSED_DIR}/storms_${Year}.parquet"

if [[ ! -f "$PARQUET_FILE" ]]; then
    echo "Converting CSV to GeoParquet..."

    ogr2ogr \
        -f Parquet \
        "$PARQUET_FILE" \
        "$CSV_FILE" \
        -oo X_POSSIBLE_NAMES=BEGIN_LON \
        -oo Y_POSSIBLE_NAMES=BEGIN_LAT \
        -oo AUTODETECT_TYPE=YES \
        -a_srs EPSG:4326

else
    echo "GeoParquet already exists. Skipping conversion."
fi

echo "Pipeline complete!"