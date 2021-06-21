FROM openjdk@sha256:0c1702c4b90c6148a9856d3154963b7499eb9efca1687ad544340f1542c85b9f

ENV VERSION 9.2.2_PUBLIC
ENV GHIDRA_SHA 8cf8806dd5b8b7c7826f04fad8b86fc7e07ea380eae497f3035f8c974de72cf8
ENV FIRMWARE_COMMIT 20210419.0
ENV GHIDRA_INSTALL_DIR /ghidra
RUN    apt-get update \
    && apt-get install -y --no-install-recommends \
                       fontconfig libxrender1 libxtst6 libxi6 wget unzip \
                       python-requests build-essential git

RUN echo "===> Obtaining Ghidra..." \
    && wget --progress=bar:force \
            -O /tmp/ghidra.zip \
            https://ghidra-sre.org/ghidra_9.2.2_PUBLIC_20201229.zip \
    && echo "$GHIDRA_SHA /tmp/ghidra.zip" | sha256sum -c - \
    && unzip /tmp/ghidra.zip \
    && mv "ghidra_${VERSION}" "$GHIDRA_INSTALL_DIR" \
    \
    && echo "===> Building firmware utils..." \
    && git clone --depth=1 \
                 https://github.com/al3xtjames/ghidra-firmware-utils.git \
                 /tmp/ghidra-firmware-utils \
    && cd /tmp/ghidra-firmware-utils \
    && git checkout -qf "$FIRMWARE_COMMIT" \
    && ./gradlew \
    \
    && echo "===> Pre-configuring Ghidra..." \
    && mkdir /preconfig/ \
    && mv dist/ghidra_9.2.2_PUBLIC_*_ghidra-firmware-utils.zip \
          /preconfig/ \
    && cd /preconfig/ \
    && unzip *.zip \
    && rm *.zip \
    && mkdir -p .ghidra/.ghidra_9.2.2_PUBLIC/Extensions \
    && mv ghidra-firmware-utils .ghidra/.ghidra_9.2.2_PUBLIC/Extensions \
    \
    && echo "===> Cleaning up unnecessary files..." \
    && apt-get purge -y --auto-remove wget unzip git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives /tmp/* /var/tmp/* \
              "$GHIDRA_INSTALL_DIR/Extensions/Eclipse" \
              "$GHIDRA_INSTALL_DIR/Extensions/IDAPro"

WORKDIR /user/host-data

COPY entrypoint.sh /entrypoint.sh
COPY preferences /preconfig/.ghidra/.ghidra_9.2.2_PUBLIC/preferences

ENTRYPOINT ["/entrypoint.sh"]
CMD [ ]
