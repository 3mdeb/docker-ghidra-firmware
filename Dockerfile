FROM openjdk:19-jdk-bullseye

ENV VERSION 10.4_PUBLIC
ENV GHIDRA_SHA 6911d674798f145f8ea723fdd3eb67a8fae8c7be92e117bca081e6ef66acac19
ENV FIRMWARE_COMMIT 20231016.0
ENV GHIDRA_INSTALL_DIR /ghidra
RUN    apt-get update \
    && apt-get install -y --no-install-recommends \
                       fontconfig libxrender1 libxtst6 libxi6 wget unzip \
                       python3-requests build-essential git

RUN echo "===> Obtaining Ghidra..." \
    && wget --progress=bar:force \
            -O /tmp/ghidra.zip \
            https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.4_build/ghidra_10.4_PUBLIC_20230928.zip \
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
    && mv dist/ghidra_${VERSION}_*_ghidra-firmware-utils.zip \
          /preconfig/ \
    && cd /preconfig/ \
    && unzip *.zip \
    && rm *.zip \
    && mkdir -p .ghidra/.ghidra_${VERSION}/Extensions \
    && mv ghidra-firmware-utils .ghidra/.ghidra_${VERSION}/Extensions \
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
