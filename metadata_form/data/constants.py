# Map 1:1 to addAttributes in datasets.xml
GLOBAL_ERDDAP_FIELDS = {
    "acknowledgment": {
        "description": "Acknowledgment or credits for data sources or contributors",
        "required": False,
    },
    "creator_country": {"description": "Country of the data creator", "required": True},
    "creator_email": {
        "description": "Email address of the data creator",
        "required": True,
    },
    "creator_institution": {
        "description": "Institution of the data creator",
        "required": True,
    },
    "creator_name": {"description": "Name of the data creator", "required": True},
    "creator_role": {
        "description": "Role of the data creator (e.g., originator, distributor)",
        "required": True,
    },
    "creator_sector": {
        "description": "Sector of the data creator (e.g., government, academia)",
        "required": False,
    },
    "creator_type": {
        "description": "Type of data creator (e.g., person, organization)",
        "required": False,
    },
    "contributor_email": {
        "description": "Email address of a data contributor",
        "required": False,
    },
    "contributor_name": {
        "description": "Name of a data contributor",
        "required": False,
    },
    "infoUrl": {
        "description": "URL for more information about the dataset",
        "required": True,
    },
    "institution": {
        "description": "Institution responsible for the dataset",
        "required": True,
    },
    "keywords": {
        "description": "Keywords or tags describing the dataset",
        "required": True,
    },
    "program": {
        "description": "Program under which the data was collected",
        "required": True,
    },
    "project": {"description": "Project associated with the dataset", "required": True},
    "sourceUrl": {"description": "URL for the original data source", "required": False},
    "subsetVariables": {
        "description": "List of variables used to subset the data.",
        "required": True,
    },
    "summary": {"description": "Brief summary of the dataset", "required": True},
    "title": {"description": "Title of the dataset", "required": True},
    "time_coverage_start": {
        "description": "Start date and time of the data coverage",
        "required": True,
    },
    "time_coverage_end": {
        "description": "End date and time of the data coverage",
        "required": True,
    },
}


DATA_VARIABLE_ERDDAP_FIELDS = [
    "destinationName",
    "ioos_category",
    "long_name",
    "standard_name",
    "units",
]

IOOS_CATEGORIES = [
    "Bathymetry",
    "Biology",
    "Bottom Character",
    "CO2",
    "Colored Dissolved Organic Matter",
    "Contaminants",
    "Currents",
    "Dissolved Nutrients",
    "Dissolved O2",
    "Ecology",
    "Fish Abundance",
    "Fish Species",
    "Heat Flux",
    "Hydrology",
    "Ice Distribution",
    "Identifier",
    "Location",
    "Meteorology",
    "Ocean Color",
    "Optical Properties",
    "Other",
    "Pathogens",
    "Phytoplankton Species",
    "Pressure",
    "Productivity",
    "Quality",
    "Salinity",
    "Sea Level",
    "Statistics",
    "Stream Flow",
    "Surface Waves",
    "Taxonomy",
    "Temperature",
    "Time",
    "Total Suspended Matter",
    "Unknown",
    "Wind",
    "Zooplankton Species",
    "Zooplankton Abundance",
]
