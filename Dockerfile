FROM ubuntu:18.04

ENV CANTALOUPE_VERSION=4.0.3

EXPOSE 8182

VOLUME /images

# Update packages and install tools
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      wget unzip graphicsmagick curl imagemagick \
      ffmpeg python default-jre && \
    rm -rf /var/lib/apt/lists/*

# Run non privileged
RUN adduser --system cantaloupe

WORKDIR /tmp

# Get and unpack Cantaloupe release archive
RUN curl -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip \
    && mkdir -p /usr/local/ \
    && cd /usr/local \
    && unzip /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip \
    && ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe \
    && rm -rf /tmp/Cantaloupe-$CANTALOUPE_VERSION \
    && rm /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip

RUN mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
    && chown -R cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
    && cp /usr/local/cantaloupe/deps/Linux-x86-64/lib/* /usr/lib/

RUN mkdir -p /etc/cantaloupe

COPY config/cantaloupe.properties /etc/cantaloupe/cantaloupe.properties
COPY config/delegates.rb /etc/cantaloupe/delegates.rb

COPY example-images/ /images/

USER cantaloupe

CMD ["sh", "-c", "java -Dcantaloupe.config=/etc/cantaloupe/cantaloupe.properties -Xmx2g -jar /usr/local/cantaloupe/cantaloupe-$CANTALOUPE_VERSION.war"]
