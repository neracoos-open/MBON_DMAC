# app/Dockerfile

FROM python:3.12-slim

WORKDIR /app

RUN mkdir metadata_form

COPY ./requirements.txt /app/requirements.txt

RUN pip3 install --no-cache-dir -r requirements.txt

COPY ./ metadata_form

EXPOSE 8501

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

ENTRYPOINT ["streamlit", "run", "metadata_form/Home.py", "--server.port=8501", "--server.address=0.0.0.0"]
