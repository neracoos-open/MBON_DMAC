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

import json
import pandas as pd
import streamlit as st
import extra_streamlit_components as stx

from data import constants
from utils import convert_forms_to_yaml, guess_metadata, validate_metadata_dict


st.set_page_config(layout="wide", page_icon=":dna:")


@st.cache_resource
def get_manager():
    return stx.CookieManager()


cookie_manager = get_manager()


if "combined_metadata" not in st.session_state:
    st.session_state["combined_metadata"] = {}

st.title("MBON Metadata Input Form")

uploaded_file = st.file_uploader("Choose a CSV file")

if uploaded_file is not None:
    # Read the CSV file into a Pandas DataFrame
    df = pd.read_csv(uploaded_file)

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
                form_data[key] = st.text_input(
                    label=key,
                    placeholder=value["description"],
                    help=value["description"],
                )

        # Add a submit button to trigger form submission
        global_submitted = st.form_submit_button("Submit")

    if global_submitted:
        # Access the form data after submission
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
                        if field == "ioos_category":
                            pre_selected_index = (
                                constants.IOOS_CATEGORIES.index(guessed_metadata[field])
                                if field in guessed_metadata
                                else 0
                            )
                            metadata[field] = st.selectbox(
                                label=field,
                                options=constants.IOOS_CATEGORIES,
                                key=f"{col}_{field_idx}",
                                index=pre_selected_index,
                            )
                        else:
                            guessed_value = (
                                guessed_metadata[field]
                                if field in guessed_metadata.keys()
                                else None
                            )
                            metadata[field] = st.text_input(
                                field,
                                key=f"{col}_{field_idx}",
                                value=guessed_value,
                            )

                    column_metadata[col] = metadata

        column_submitted = st.form_submit_button("Submit")

    if column_submitted or ("output_yaml" in st.session_state and st.session_state["output_yaml"]):
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
    save_button = st.button("Save Progress")
    if save_button:
        # Get data from both forms (assuming form_submit_button not used)
        global_metadata = st.session_state["global_metadata_form"]  # Assuming data stored in session_state
        metadata = st.session_state["metadata_form"]  # Assuming data stored in session_state

        # Combine form data
        combined_data = {"global_metadata": global_metadata, "metadata": metadata}

        # Save data to a downloadable file
        try:
            # Convert data to JSON string
            json_data = json.dumps(combined_data)

            # Download button with filename and data
            st.download_button(
                label="Download Saved Progress",
                data=json_data.encode("utf-8"),
                file_name="saved_progress.json",
                mime="application/json",
            )
            st.success("Data ready for download!")
        except Exception as e:
            st.error(f"Error saving data: {e}")

else:
    st.write("Please upload a CSV file to view its contents.")
