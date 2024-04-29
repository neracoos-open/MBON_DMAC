"""
Utilities to help process & validate metadata input
"""
import yaml

from data import heuristic_metadata


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


def guess_metadata(variable_name) -> dict | None:
    """
    Guesses metadata for a variable based on heuristics.

    Iterates through `heuristic_metadata.variable_metadata_guess`
    and assigns potential values for matching field names and targets.

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
