# app/Dockerfile

FROM python:3.12-slim@sha256:f11725aba18c19664a408902103365eaf8013823ffc56270f921d1dc78a198cb

WORKDIR /app

RUN mkdir metadata_form
RUN mkdir metadata_form/data

COPY ./requirements.txt requirements.txt

RUN pip3 install --no-cache-dir -r requirements.txt

COPY ./Home.py utils.py metadata_form/
COPY ./data metadata_form/data/

EXPOSE 8501

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

ENTRYPOINT ["streamlit", "run", "metadata_form/Home.py", "--server.port=8501", "--server.address=0.0.0.0", "--browser.serverAddress=mbon.metadata.neracoos.org"]
