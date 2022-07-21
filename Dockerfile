ARG JAVA_VERSION=8u332b09
ARG JAVA_VERSION_URL=jdk8u332-b09
ARG JAVA_SYMLINK_NAME=jre-8
ARG JAVA_SHA256_CHECKSUM=34454309b43d585047baaefc36c1850d0192cccc8b52cdc4aadb192b8e3e4c81

# =============================================================================
# ========== Download JRE
# =============================================================================
FROM kristinjeanna/ubuntu:latest AS jre-downloader

USER root

# JRE8 args
ARG JAVA_VERSION
ARG JAVA_VERSION_URL
ARG JAVA_RELEASE_URL=https://github.com/adoptium/temurin8-binaries/releases/download/${JAVA_VERSION_URL}
ARG JAVA_FILENAME=OpenJDK8U-jre_x64_linux_hotspot_${JAVA_VERSION}.tar.gz
ARG JAVA_EXTRACT_DIR=jre${JAVA_VERSION}
ARG JAVA_SHA256_CHECKSUM
ARG JAVA_SYMLINK_NAME

# download JRE8, verify hash, and extract
RUN mkdir /opt/${JAVA_EXTRACT_DIR} && \
	cd /opt && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y wget && \
	wget ${JAVA_RELEASE_URL}/${JAVA_FILENAME} && \
	echo "${JAVA_SHA256_CHECKSUM} ${JAVA_FILENAME}" | sha256sum -c - && \
	tar -xzv -C ${JAVA_EXTRACT_DIR} -f ${JAVA_FILENAME} --strip-components=1 && \
	ln -s ${JAVA_EXTRACT_DIR} ${JAVA_SYMLINK_NAME} && \
	rm ${JAVA_FILENAME}

# =============================================================================
# ========== Assemble the final docker image
# =============================================================================
FROM kristinjeanna/ubuntu:latest AS final

ARG JAVA_VERSION
ARG JAVA_SYMLINK_NAME

LABEL "java.version"="${JAVA_VERSION}"

ENV JAVA_HOME=/opt/${JAVA_SYMLINK_NAME}
ENV PATH=${JAVA_HOME}/bin:${PATH}

# copy the downloaded Java JRE
COPY --from=jre-downloader /opt /opt

CMD ["bash"]
