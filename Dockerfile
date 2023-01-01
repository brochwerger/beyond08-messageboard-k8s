FROM registry.access.redhat.com/ubi8/python-38

# Expose port used by our app server
EXPOSE 8000

# Install dependencies into container
COPY requirements.txt . 
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Install application into container
WORKDIR /app

USER root
COPY . .
RUN chown -R 1001:0 /app
USER 1001

VOLUME [ "/data" ]

# Run the application
ENTRYPOINT [ "/app/docker-entrypoint.sh" ]
