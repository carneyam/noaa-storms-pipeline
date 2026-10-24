# NOAA Storms Pipeline

A one-command pipeline that downloads a year of NOAA Storm Events data, converts it to GeoParquet, and lands it ready for analysis in DuckDB, GeoPandas, or QGIS.

## What it does

## What it does

`pipeline.sh` automates the download, extraction, and conversion of NOAA Storm Events data into GeoParquet.

The pipeline:

1. Accepts a storm event year (default: 2024).
2. Automatically identifies the most recent NOAA dataset revision for that year, unless a specific creation date is provided.
3. Downloads the compressed CSV file from NOAA's public archive.
4. Extracts the CSV and converts it into GeoParquet using GDAL, creating point geometries from the beginning latitude and longitude fields.
5. Saves the processed dataset to `data/processed/storms_{YEAR}_c{CREATED_DATE}.parquet`.

The script uses temporary files to reduce the risk of incomplete outputs and skips existing files during subsequent executions.

Runtime varies by dataset size, internet connection, and whether the source files have already been processed. Subsequent runs skip completed processing stages.

## The data

- **Source:** [NOAA Storm Events Database](https://www.ncei.noaa.gov/data/storm-events/)
- **License:** Public domain (US federal data)
- **What's in it:** every recorded storm event in the United States for the given year, including type, location, and damages

### Data validation (2024)

- Total records: 69,801
- Records with non-null point geometry: 42,190 (60.4%)
- Records with missing geometry: 27,611 (39.6%)
- Missing geometries correspond to missing latitude/longitude values.
- Geometry type: Point
- Coordinate reference system: EPSG:4326 (WGS 84)

Records without coordinates are preserved in the GeoParquet output.

## How to run it

Clone the repository:
```bash
git clone https://github.com/carneyam/noaa-storms-pipeline.git
cd noaa-storms-pipeline
chmod +x pipeline.sh
```

Process 2024 (default):
```bash
./pipeline.sh
```

Process a specific year using the latest available revision:
```bash
./pipeline.sh 2023
```

Process a specific year and creation date:
```bash
./pipeline.sh 2023 20260323
```

## Created file location
The processed GeoParquet file is saved in the project's `data/processed/` directory using the naming convention:

`storms_{YEAR}_c{CREATED_DATE}.parquet`

For example, processing the 2023 dataset created on March 23, 2026, produces:

`data/processed/storms_2023_c20260323.parquet`

The output directory is created automatically within the repository's local folder, regardless of where the script is executed. Different NOAA revisions are saved as separate files, preserving the source creation date.

The `data/` directory is excluded from Git and is not uploaded to GitHub.

## What I learned

Building this pipeline helped me develop practical experience with Bash scripting, GDAL, and automated geospatial data processing. I learned how to troubleshoot shell variable naming and syntax errors, construct dynamic download URLs, and make a workflow repeatable without unnecessarily downloading or processing existing files.

I also learned the importance of validating spatial outputs. Although the pipeline successfully converted 69,801 NOAA storm event records to GeoParquet, I identified that some points lacked the coordinates necessary to create point geometries. Rather than discarding those records, they are preserved for potential nonspatial analysis.

## Stack

- bash
- curl
- GDAL / ogr2ogr
- GeoParquet
