FROM python:3.6.9

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV POETRY_VERSION=1.1.7
ENV ARTIFACTORY_USERNAME=ghbi_service
ENV ARTIFACTORY_PASSWORD=Password123
ENV ARTIFACTORY_URL=https://artifactory01.ghdna.io/artifactory

RUN pip install "poetry==$POETRY_VERSION"

WORKDIR /app

COPY pyproject.toml poetry.lock /app/
COPY hello_world_pkg /app/hello_world_pkg/
RUN poetry config virtualenvs.create false \
    && poetry install $(test "ENVIRONMENT" == production && echo "--no-dev") \
      --no-interaction \
      --no-ansi

RUN groupadd --gid $SENTINELGID sentinel_group
RUN useradd --uid $SENTINELUID -p sentinel --gid sentinel_group --shell /bin/bash --create-home sentinel
RUN chmod 755 /home/sentinel

