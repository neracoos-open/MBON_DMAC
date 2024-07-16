# app/Dockerfile

FROM python:3.12-slim

WORKDIR /app

RUN mkdir metadata_form

# RUN apt-get update && apt-get install -y \
#     build-essential \
#     curl \
#     software-properties-common \
#     git \
#     && rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt /app/requirements.txt

COPY ./startup_commands.sh /app/startup_commands.sh
RUN ["chmod", "+x", "/app/startup_commands.sh"]

RUN pip3 install --no-cache-dir -r requirements.txt

COPY ./ metadata_form

EXPOSE 8501

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

ENTRYPOINT ["streamlit", "run", "streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]