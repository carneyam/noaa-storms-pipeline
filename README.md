# NOAA Storms Pipeline

A one-command pipeline that downloads a year of NOAA Storm Events data, converts it to GeoParquet, and lands it ready for analysis in DuckDB, GeoPandas, or QGIS.

## What it does

`pipeline.sh` takes a year (default: 2024), pulls the raw `details` file from NOAA's public archive, decompresses it, and converts it to a single GeoParquet file at `data/processed/storms_{YEAR}.parquet`.

Total runtime: about 90 seconds for a typical year on a home internet connection.

## The data

- **Source:** [NOAA Storm Events Database](https://www.ncei.noaa.gov/data/storm-events/)
- **License:** Public domain (US federal data)
- **What's in it:** every recorded storm event in the United States for the given year, including type, location, and damages

### Data validation (2024)

- Total records: 69,801
- Records with valid point geometry: 42,190 (60.4%)
- Records with missing geometry: 27,611 (39.6%)
- Missing geometries correspond to missing latitude/longitude values.
- Geometry type: Point
- Coordinate reference system: EPSG:4326 (WGS 84)

Records without coordinates are preserved in the GeoParquet output.

## How to run it

Requires GDAL (for `ogr2ogr`) and standard Unix utilities (`curl`, `gunzip`).

## Process 2024 (default)
./pipeline.sh

## Process a specific year
./pipeline.sh 2023

## What I learned

Building this pipeline helped me develop practical experience with Bash scripting, GDAL, and automated geospatial data processing. I learned how to troubleshoot shell variable naming and syntax errors, construct dynamic download URLs, and make a workflow repeatable without unnecessarily downloading or processing existing files.

I also learned the importance of validating spatial outputs. Although the pipeline successfully converted 69,801 NOAA storm event records to GeoParquet, I identified that some points lacked the coordinates necessary to create point geometries. Rather than discarding those records, they are preserved for potential nonspatial analysis.

## Stack

- bash
- curl
- GDAL / ogr2ogr
- GeoParquet
