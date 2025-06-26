"""
**MBON Metadata Input Form**

This Streamlit application provides a user interface for inputting and validating MBON
(Marine Biodiversity Observation Network) metadata.
Users submit data for multiple variables, and the form performs validation
checks to ensure required fields are present.

**Functionality:**

* Users can enter metadata for each variable using a form.
* The form validates entered metadata against pre-defined required keys.
* If validation fails an error message is displayed indicating the missing key.
* Once all variables are validated, the combined metadata is converted to YAML format.
* The YAML metadata is displayed and can be downloaded as a file (metadata.yaml).
"""

import pandas as pd
import streamlit as st
import yaml

from data import constants
from utils import convert_forms_to_yaml, guess_metadata, validate_metadata_dict


st.set_page_config(layout="wide", page_icon=":dna:")

# --- Save/Load Progress Controls ---
with st.sidebar:
    st.header("Save/Load Progress")
    # Save Progress
    checkpoint_filename = "metadata_checkpoint.yaml"
    if st.session_state.get('uploaded_csv_name'):
        base = st.session_state['uploaded_csv_name'].rsplit('.', 1)[0]
        checkpoint_filename = f"{base}_metadata_checkpoint.yaml"
    if st.session_state.get('combined_metadata'):
        checkpoint_yaml = yaml.dump(st.session_state['combined_metadata'])
        st.download_button(
            label="Download Checkpoint",
            data=checkpoint_yaml,
            file_name=checkpoint_filename,
            mime="text/yaml",
        )
    # Load Progress
    uploaded_progress = st.file_uploader("Load Progress", type=["yaml", "yml"], key="progress_upload")
    if uploaded_progress:
        try:
            loaded_data = yaml.safe_load(uploaded_progress)
            if isinstance(loaded_data, dict):
                st.session_state["combined_metadata"] = loaded_data
                st.success("Progress loaded! Continue editing your metadata.")
            else:
                st.error("Uploaded file is not a valid YAML dictionary.")
        except Exception as e:
            st.error(f"Failed to load YAML: {e}")

if "combined_metadata" not in st.session_state:
    st.session_state["combined_metadata"] = {}

st.header("MBON Metadata Input Form", divider="rainbow")

uploaded_file = st.file_uploader("Choose a CSV file")

if uploaded_file is not None:
    # Read the CSV file into a Pandas DataFrame
    df = pd.read_csv(uploaded_file)
    st.session_state['uploaded_csv_name'] = uploaded_file.name

    # Place the DataFrame in an expander
    with st.expander("Preview"):
        st.dataframe(df)  # Display the entire DataFrame

    # Form for user input
    st.write("**Global Metadata**")
    with st.form("global_metadata_form"):
        form_data = {}
        num_fields = len(constants.GLOBAL_ERDDAP_FIELDS.keys())
        cols = st.columns(
            min(num_fields, 5),
        )  # Create columns based on the number of fields, up to 5
        for field_idx, (key, value) in enumerate(
            constants.GLOBAL_ERDDAP_FIELDS.items(),
        ):
            with cols[
                field_idx % len(cols)
            ]:  # Place fields in columns in a circular fashion
                prefill_val = st.session_state["combined_metadata"].get("global", {}).get(key, "")
                form_data[key] = st.text_input(
                    label=key,
                    placeholder=value["description"],
                    help=value["description"],
                    value=prefill_val,
                )
        # Add a submit button to trigger form submission
        global_submitted = st.form_submit_button("Submit")

    if global_submitted:
        # Save the current data as a checkpoint, even if it's not valid yet
        st.session_state['combined_metadata']['global'] = form_data
        # Now proceed with validation as before
        required_fields = [
            key
            for key, value in constants.GLOBAL_ERDDAP_FIELDS.items()
            if value["required"] is True
        ]

        validation_result, missing_key = validate_metadata_dict(
            metadata=form_data,
            required_keys=required_fields,
        )

        if validation_result:
            st.success("Metadata is valid!")
            # st.write(form_data)
            st.session_state["combined_metadata"]["global"] = form_data
        else:
            st.error(f"Metadata is invalid. Missing value for key: '{missing_key}'")

    # Form for editing column metadata
    st.write("**Variable Metadata**")
    with st.form("metadata_form"):
        column_metadata = {}

        cols = st.columns(
            min(len(df.columns), 4),
        )  # Create columns for up to 4 columns at a time
        for col_idx, col in enumerate(df.columns):
            guessed_metadata = guess_metadata(col)
            with cols[col_idx % len(cols)]:  # Place collapsible sections in columns
                with st.expander(f"{col}", expanded=True):
                    metadata = {}
                    for field_idx, field in enumerate(
                        constants.DATA_VARIABLE_ERDDAP_FIELDS,
                    ):
                        prefill_val = st.session_state["combined_metadata"].get("var_data", {}).get(col, {}).get(field, guessed_metadata.get(field, ""))
                        if field == "ioos_category":
                            if prefill_val in constants.IOOS_CATEGORIES:
                                pre_selected_index = constants.IOOS_CATEGORIES.index(prefill_val)
                            else:
                                pre_selected_index = 0
                            metadata[field] = st.selectbox(
                                label=field,
                                options=constants.IOOS_CATEGORIES,
                                key=f"{col}_{field_idx}",
                                index=pre_selected_index,
                            )
                        else:
                            metadata[field] = st.text_input(
                                field,
                                key=f"{col}_{field_idx}",
                                value=prefill_val,
                            )
                    column_metadata[col] = metadata

        column_submitted = st.form_submit_button("Submit")

    if column_submitted or ("output_yaml" in st.session_state and st.session_state["output_yaml"]):
        # Save the current data as a checkpoint, even if it's not valid yet
        st.session_state['combined_metadata']['var_data'] = column_metadata

        required_var_fields = [
            key
            for key, value in constants.DATA_VARIABLE_ERDDAP_FIELDS.items()
            if value["required"] is True
        ]

        all_valid = True
        for key, value in column_metadata.items():
            validation_result, missing_key = validate_metadata_dict(
                metadata=value,
                required_keys=required_var_fields,
            )
            if not validation_result:
                st.error(
                    f"Metadata is invalid. Missing value:\
                          '{missing_key}' for variable: '{key}'",
                )
                all_valid = False
                break

        if all_valid:
            # Access the form data after submission
            st.session_state["combined_metadata"]["var_data"] = column_metadata
            output_yaml = convert_forms_to_yaml(st.session_state["combined_metadata"])
            st.session_state["output_yaml"] = output_yaml

            st.code(body=output_yaml, language="yaml", line_numbers=True)
            st.download_button(
                label="Download metadata",
                data=output_yaml,
                file_name="metadata.yaml",
            )

else:
    st.write("Please upload a CSV file to view its contents.")
