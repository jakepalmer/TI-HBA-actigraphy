FROM rocker/tidyverse:4.1.0

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

RUN install2.r --error \
    --deps TRUE \
    GGIR
