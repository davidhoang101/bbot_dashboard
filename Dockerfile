FROM continuumio/miniconda3:latest

ARG DASHBOARD_REPO=https://github.com/davidhoang101/bbot-dashboard.git
ARG DASHBOARD_BRANCH=main

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    libffi-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libblas-dev \
    liblapack-dev \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/dashboard

# Clone your actual repo that contains main.py, requirements.txt, etc.
RUN git clone --branch ${DASHBOARD_BRANCH} ${DASHBOARD_REPO} .

# Build conda environment from the repo's environment.yml
RUN conda env create -f environment.yml && \
    /opt/conda/envs/dashboard/bin/pip install --no-cache-dir -r requirements.txt && \
    conda clean -afy

SHELL ["/bin/bash", "-c"]
RUN echo "conda activate dashboard" >> ~/.bashrc

EXPOSE 8501

ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "dashboard", "streamlit", "run", "main.py", "--server.port=8501", "--server.address=0.0.0.0"]