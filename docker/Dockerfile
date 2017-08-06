FROM java:8-jre
MAINTAINER Wade Schulz / Adapted from xemuliam/hdf-base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qqy update && apt-get -qqy install \
		curl \
        krb5-user \
        python \
        unzip \
        vim

# download Java Cryptography Extension
RUN cd /tmp/ && \
    curl -LO "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" -H 'Cookie: oraclelicense=accept-securebackup-cookie' && \
    unzip jce_policy-8.zip && \
    rm jce_policy-8.zip && \
    yes |cp /tmp/UnlimitedJCEPolicyJDK8/*.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/

COPY krb5.conf /etc/krb5.conf

ARG        DIST=https://public-repo-1.hortonworks.com/HDF/3.0.1.0/nifi-1.2.0.3.0.1.0-43-bin.tar.gz
ARG        VERSION=1.2.0.3.0.1.0-43
ENV        HDF_HOME=/opt/hdf
RUN        mkdir -p ${HDF_HOME} && \
           curl ${DIST} | tar xvz -C ${HDF_HOME} && \
           mv ${HDF_HOME}/nifi-${VERSION}/* ${HDF_HOME} && \
           rm -rf ${HDF_HOME}/nifi-${VERSION} && \
           rm -rf nifi-${VERSION}-bin.tar.gz
EXPOSE     8080 8081 8443
VOLUME     ${HDF_HOME}/logs \
           ${HDF_HOME}/flowfile_repository \
           ${HDF_HOME}/database_repository \
           ${HDF_HOME}/content_repository \
           ${HDF_HOME}/provenance_repository
WORKDIR    ${HDF_HOME}

COPY authority-providers.xml /opt/hdf/conf/authority-providers.xml
COPY authorized-users.xml /opt/hdf/conf/authorized-users.xml
COPY login-identity-providers.xml /opt/hdf/conf/login-identity-providers.xml
COPY run.sh /opt/hdf/run.sh
RUN chmod +x /opt/hdf/run.sh
CMD ./run.sh
