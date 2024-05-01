# MBON DMAC
This is the central hub to facilitate data management and archiving workflows for the Integrated Sustained Marine Observing Network (ISMN) and the Marine Biodiversity Observation Network (MBON) projects.

# Target Users

This repository is intended for:
- ISMN/MBON data providers: Researchers responsible for submitting data and metadata to the ISMN/MBON project.
- Data managers: Individuals tasked with managing data submissions, processing workflows, and ensuring data quality within the project.

# Getting Started

- Open a new issue
    - Use the "New Dataset" template
    - This template will guide you through the data submission process
- Fill out required fields
- Provide valid metadata
    - Ensure that metadata adheres to MBON standards. [The MBON Metadata Form](https://mbon-metadata.streamlit.app/) can help generate/validate your metadata during the submission process.

# Example: "Gold Standard" Metadata

```YAML
global:
  add:
    acknowledgment: Data collection was supported by multiple awards to NERACOOS,
      the University of New Hampshire             and the University of Maine from
      various funding agencies, including NSF, NOAA and BOEM.
    contributor_email: jackie@neracoos.org
    contributor_name: NERACOOS ISMN
    creator_country: USA
    creator_email: jeffrey.runge@maine.edu
    creator_institution: School of Marine Sciences, University of Maine, Darling Marine
      Center
    creator_name: Jeffrey Runge, Ph.D
    creator_role: PI
    creator_sector: academic
    creator_type: person
    infoUrl: https://www.sentinelmonitoring.org/
    institution: University of Maine/NERACOOS
    keywords: Biodiversity, plankton, Gulf of Maine, time series, Calanus
    program: NERACOOS
    project: NERACOOS
    sourceUrl: local files
    subsetVariables: Station_ID, Mesh_Size
    summary: Coastal Maine Time Series Station (CMTS)
    time_coverage_end: '2023-08-12T00:11:00-05:00'
    time_coverage_start: '2020-08-12T00:11:00-05:00'
    title: Gulf of Maine CMTS Calanus Abundance Observations, since 2020
variables:
  CAST:
    add:
      destinationName: Cast
      ioos_category: Unknown
      long_name: Cast number for a given date
      standard_name: null
      units: null
  COMMENT:
    add:
      destinationName: COMMENT
      ioos_category: Unknown
      long_name: Comment
      standard_name: null
      units: null
  CRUISE_ID:
    add:
      destinationName: CRUISE_ID
      ioos_category: Identifier
      long_name: Cruise Identification Label
      standard_name: null
      units: null
  Calanus_finmarchicus_CI:
    add:
      destinationName: Calanus_finmarchicus_CI
      ioos_category: Unknown
      long_name: Calanus Finmarchicus stage CI
      standard_name: null
      units: Number of stage CI per m2
  Calanus_finmarchicus_CII:
    add:
      destinationName: Calanus_finmarchicus_CII
      ioos_category: Unknown
      long_name: Calanus Finmarchicus stage CII
      standard_name: null
      units: Number of stage CII per m2
  Calanus_finmarchicus_CIII:
    add:
      destinationName: Calanus_finmarchicus_CIII
      ioos_category: Unknown
      long_name: Calanus Finmarchicus stage CIII
      standard_name: null
      units: Number of stage CIII per m2
  Calanus_finmarchicus_CIV:
    add:
      destinationName: Calanus_finmarchicus_CIV
      ioos_category: Unknown
      long_name: Calanus Finmarchicus stage CIV
      standard_name: null
      units: Number of stage CIV per m2
  Calanus_finmarchicus_CV:
    add:
      destinationName: Calanus_finmarchicus_CV
      ioos_category: Unknown
      long_name: Calanus Finmarchicus stage CV
      standard_name: null
      units: Number of stage CV per m2
  Calanus_finmarchicus_F:
    add:
      destinationName: Calanus_finmarchicus_F
      ioos_category: Unknown
      long_name: Calanus Finmarchicus stage CVI Female
      standard_name: null
      units: Number of adult females per m2
  Calanus_finmarchicus_M:
    add:
      destinationName: Calanus_finmarchicus_M
      ioos_category: Unknown
      long_name: Calanus Finmarchicus stage CVI Male
      standard_name: null
      units: Number of adult males per m2
  Calanus_finmarchicus_N:
    add:
      destinationName: Calanus_finmarchicus_N
      ioos_category: Statistics
      long_name: Calanus Finmarchicus Nauplius stages
      standard_name: null
      units: Number of all nauplius stages per m2
  DW(G_M-2):
    add:
      destinationName: DW_G_M_2
      ioos_category: Unknown
      long_name: DW(G M-2)
      standard_name: null
      units: g/m2
  KEY:
    add:
      destinationName: Cruise_Identification_Tag
      ioos_category: Unknown
      long_name: Cruise Identification Tag
      standard_name: null
      units: null
  LAT_(DECIMAL):
    add:
      destinationName: latitude
      ioos_category: Location
      long_name: Latitude
      standard_name: latitude
      units: degrees_north
  LON_(DECIMAL):
    add:
      destinationName: longitude
      ioos_category: Location
      long_name: Longitude
      standard_name: longitude
      units: degrees_east
  MESH:
    add:
      destinationName: Mesh_Size
      ioos_category: Unknown
      long_name: Net mesh size
      standard_name: null
      units: microns
  NET_AREA:
    add:
      destinationName: Plankton_Net_Area
      ioos_category: Unknown
      long_name: Area of plankton net
      standard_name: null
      units: m2
  NET_DEPTH:
    add:
      destinationName: NET_DEPTH
      ioos_category: Location
      long_name: Maximum depth net deployed
      standard_name: null
      units: meters
  NET_ID:
    add:
      destinationName: Net_Type
      ioos_category: Unknown
      long_name: Net characteristics
      standard_name: null
      units: null
  SAMP_DW(G):
    add:
      destinationName: Sample_Dry_Weight
      ioos_category: Unknown
      long_name: Sample Dry Weight
      standard_name: null
      units: g
  SPLIT:
    add:
      destinationName: Sample_Split
      ioos_category: Unknown
      long_name: Sample split identifier
      standard_name: null
      units: null
  STATION:
    add:
      destinationName: Station_ID
      ioos_category: Identifier
      long_name: Station Identifier
      standard_name: null
      units: null
  STATION_DEPTH:
    add:
      destinationName: STATION_DEPTH
      ioos_category: Location
      long_name: Depth of station
      standard_name: null
      units: meters
  TOTAL_DILFACTOR_(CFIN):
    add:
      destinationName: TOTAL_DILFACTOR_CFIN
      ioos_category: Unknown
      long_name: TOTAL DILFACTOR (CFIN)
      standard_name: null
      units: g
  TOTAL_DILFACTOR_(OTHER):
    add:
      destinationName: Dilution_Factor
      ioos_category: Unknown
      long_name: Dilution factor
      standard_name: null
      units: g
  VOL_FILT:
    add:
      destinationName: Volume_Filtered
      ioos_category: Unknown
      long_name: Volume cleared by plankton net
      standard_name: null
      units: m3
  time:
    add:
      destinationName: time
      ioos_category: Time
      long_name: Time
      standard_name: time
      units: null
```

# Additional Resources
- MBON datasets in ERDDAP
    - [CMTS Calanus Abundance Observations, 2007 - 2017](https://data.neracoos.org/erddap/tabledap/CMTS_CFIN_2007_2017.html)
    - [CMTS Calanus Abundance Observations, since 2020](https://data.neracoos.org/erddap/tabledap/CMTS_CFIN_start_2020.html)
    - [WBTS Calanus Abundance Observations, 2004 - 2017](https://data.neracoos.org/erddap/tabledap/WBTS_CFIN_2004_2017.html)
    - [WBTS Calanus Abundance Observations, since 2020](https://data.neracoos.org/erddap/tabledap/WBTS_CFIN_start_2020.html)

- [WBTS Darwin Core Reference](https://github.com/ioos/bio_data_guide/tree/main/datasets/WBTS_MBON)
- [WBTS Darwin Core Discussion](https://github.com/ioos/bio_data_guide/issues/102)
- [WBTS Dataset on OBIS](https://obis.org/dataset/5ef55cd8-05a1-4569-8e17-ceb224e40f59)
- [WBTS Dataset on GBIF](https://www.gbif.org/dataset/29651377-23c8-4f45-b439-693a1a23cee1)
- MBON Datasets in Other ERDDAPs or MBON Catalog: (Will populate as they become available)


# Contact
Please open an issue and assign @Dylan-Pugh