#!/usr/bin/env bash

set -euo pipefail

# NOAA Storm Events Data Pipeline
# Downloads and processes annual storm event records

# Configuration
Year="${1:-2024}"
CREATED_DATE="${2:-}"

BASE_URL="https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles" 
RAW_DIR="data/raw"
PROCESSED_DIR="data/processed"

#Create directories if they do not exist
mkdir -p "$RAW_DIR" "$PROCESSED_DIR"

echo "Starting NOAA Storm Events Data Pipeline..."
echo "Processing NOAA Storm Events for year: $Year"

# Find the NOAA file for the selected year and optional creation date
if [[ -n "$CREATED_DATE" ]]; then

    # Use the creation date supplied by the user
    FILENAME="StormEvents_details-ftp_v1.0_d${Year}_c${CREATED_DATE}.csv.gz"

    echo "Using specified creation date: $CREATED_DATE"

else

    # Discover the latest available file for the selected year
    echo "Searching NOAA archive for ${Year}..."

    FILENAME=$(
        curl -fsSL "$BASE_URL/" \
        | grep -o "StormEvents_details-ftp_v1\.0_d${Year}_c[0-9]*\.csv\.gz" \
        | sort -u \
        | tail -n 1
    )

fi

# Check whether a filename was found
if [[ -z "$FILENAME" ]]; then
    echo "ERROR: No NOAA file found for ${Year}."
    exit 1
fi

echo "Selected NOAA file: $FILENAME"

# Extract the creation date from the filename
FILE_CREATED_DATE="${FILENAME##*_c}"
FILE_CREATED_DATE="${FILE_CREATED_DATE%.csv.gz}"

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

if [[ ! -f "$CSV_FILE" ]]; then
    echo "Extracting CSV..."
    gzip -dc "$RAW_FILE" > "$CSV_FILE"
else
    echo "Extracted CSV already exists. Skipping extraction."
fi

# Convert CSV to GeoParquet
PARQUET_FILE="${PROCESSED_DIR}/storms_${Year}_c${FILE_CREATED_DATE}.parquet"

echo "Output GeoParquet: $PARQUET_FILE"

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