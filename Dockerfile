# Adapted from https://github.com/MITLibraries/docker-cantaloupe/blob/master/Dockerfile

FROM openjdk:10-slim

ENV CANTALOUPE_VERSION=4.0.2
#ENV IMAGEMAGICK_VERSION=7.0.8-14

EXPOSE 8182

VOLUME /images

# Update packages and install tools
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends wget unzip graphicsmagick curl imagemagick ffmpeg python && \
    rm -rf /var/lib/apt/lists/*

# Run non privileged
RUN adduser --system cantaloupe

WORKDIR /tmp

# KAKADU Install
RUN mkdir -p /tools && \
    cd /tools && \
    wget -O kakadu.zip http://kakadusoftware.com/wp-content/uploads/2014/06/KDU7A2_Demo_Apps_for_Ubuntu-x86-64_170827.zip && \
    unzip kakadu.zip -d kakadu && \
    rm -f kakadu.zip

ENV PATH /tools/kakadu/KDU7A2_Demo_Apps_for_Ubuntu-x86-64_170827:${PATH}
ENV LD_LIBRARY_PATH /tools/kakadu/KDU7A2_Demo_Apps_for_Ubuntu-x86-64_170827:${LD_LIBRARY_PATH}

#ImageMagick 7 install - re-evaluate once officially deprecated
#RUN cd /tools && \
#    wget http://imagemagick.org/download/releases/ImageMagick-$IMAGEMAGICK_VERSION.tar.xz && \
#    tar -xf ImageMagick-$IMAGEMAGICK_VERSION.tar.xz && \
#    cd ImageMagick-$IMAGEMAGICK_VERSION && \
#    ./configure --prefix /usr/local && \
#    make && \
#    make install && \
#    cd .. && \
#    ldconfig /usr/local/lib && \
#    rm -rf  ImageMagick*

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
# ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh", "-c", "java -Dcantaloupe.config=/etc/cantaloupe/cantaloupe.properties -Xmx2g -jar /usr/local/cantaloupe/cantaloupe-$CANTALOUPE_VERSION.war"]