"""
Utilities to help process & validate metadata input
"""
import yaml
import pandas as pd

from data import heuristic_metadata


# Simple global cache for the CF standard names DataFrame
_CF_STANDARD_NAMES_DF = None

def load_cf_standard_names():
    if _CF_STANDARD_NAMES_DF is None:
        url = 'https://cfconventions.org/Data/cf-standard-names/current/src/cf-standard-name-table.xml'
        _CF_STANDARD_NAMES_DF = pd.read_xml(url, xpath='entry')
    return _CF_STANDARD_NAMES_DF


def validate_metadata_dict(metadata: dict, required_keys: list[str]):
    """
    Validates a metadata dictionary for required keys and non-empty values.

    Args:
        metadata (dict): The metadata dictionary to validate.
        required_keys (list[str]): Keys to validate against.

    Returns:
        bool: True if all required keys are present with non-empty values.
        str: The first missing key or the first key with an empty value.
    """

    for key in required_keys:
        if key not in metadata:
            return False, key  # Missing key
        elif not metadata[key]:
            return False, key  # Empty value

    return True, None  # All keys present with non-empty values


def get_cf_canonical_unit(standard_name: str) -> str | None:
    """
    Looks up the canonical unit for a given CF standard name in the loaded DataFrame.
    Returns the canonical unit string if found, else None.
    """
    df = load_cf_standard_names()
    match = df[df['@id'] == standard_name]
    if not match.empty:
        return match.iloc[0].get('canonical_units')
    return None


def guess_metadata(variable_name) -> dict | None:
    """
    Guesses metadata for a variable based on heuristics and CF standard names.

    Iterates through `heuristic_metadata.variable_metadata_guess`
    and assigns potential values for matching field names and targets.
    If a CF standard name match is found, includes the canonical unit.

    Returns: Guessed metadata dict or None if no match found.
    """
    accepted_metadata = {}
    for (
        field_name,
        potential_values,
    ) in heuristic_metadata.variable_metadata_guess.items():
        for (
            accepted_value,
            target,
        ) in potential_values.items():  # Iterate through values of inner dict
            if variable_name in target:
                accepted_metadata[
                    field_name
                ] = accepted_value  # Assign the entire accepted value

    # If a standard_name is guessed, try to get canonical unit from CF table
    std_name = accepted_metadata.get('standard_name')
    if std_name:
        cf_unit = get_cf_canonical_unit(std_name)
        if cf_unit:
            accepted_metadata['units'] = cf_unit

    return accepted_metadata


def convert_forms_to_yaml(data_dict):
    """
    Converts variable data to YAML format suitable for defining variables.

    Args:
        data_dict (dict): Dict containing global & variable level attributes.

    Returns:
        str: YAML formatted data representing the variables.
    """
    output_dict = {"global": {}, "variables": {}}

    # Add global attributes (if present)
    if "global" in data_dict:
        output_dict["global"] = {"add": data_dict["global"]}

    # Process variable data
    for var_name, var_info in data_dict["var_data"].items():
        output_dict["variables"][var_name] = {
            "add": {
                "destinationName": var_info.get("destinationName"),
                "standard_name": var_info.get("standard_name", None),
                "long_name": var_info.get("long_name", None),
                "ioos_category": var_info.get("ioos_category", None),
                "units": var_info.get("units", None),
            },
        }
    return yaml.dump(output_dict)


def validate_cf_standard_name(name: str) -> bool:
    """
    Checks if the input string is a valid CF standard name by looking it up in the CF standard name table XML.
    Args:
        name (str): The standard name to validate.
    Returns:
        bool: True if the name is present in the CF table, False otherwise.
    """
    df = load_cf_standard_names()
    return name in set(df['@id'])
