FROM java:8-jre
MAINTAINER Wade Schulz / Adapted from Andrew Grande

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qqy update && apt-get -qqy install \
        krb5-user \
        python

COPY krb5.conf /etc/krb5.conf

#RUN wget --no-verbose http://apache.mirrors.lucidnetworks.net/nifi/0.6.1/nifi-0.6.1-bin.tar.gz && tar zxf nifi*.tar.gz && rm -f nifi*.tar.gz
#RUN wget --no-verbose http://public-repo-1.hortonworks.com/HDF/1.1.1.0/nifi-1.1.1.0-12-bin.tar.gz && tar zxf nifi*.tar.gz && rm -f nifi*.tar.gz
#RUN wget --no-verbose http://public-repo-1.hortonworks.com/HDF/centos7/1.x/updates/1.2.0.0/HDF-1.2.0.0-91.tar.gz && tar zxf HDF*.tar.gz && rm -f HDF*.tar.gz
#RUN wget --no-verbose http://public-repo-1.hortonworks.com/HDF/2.0.1.0/HDF-2.0.1.0-12.tar.gz && tar zxf HDF*.tar.gz && rm -f HDF*.tar.gz
RUN wget --no-verbose http://public-repo-1.hortonworks.com/HDF/centos7/2.x/updates/2.1.2.0/HDF-2.1.2.0-centos7-tars-tarball.tar.gz && tar zxf HDF*.tar.gz && rm -f HDF*.tar.gz

VOLUME ["/output", "/flowconf", "/flowrepo",  "/contentrepo", "/databaserepo", "/provenancerepo"]

#ENV NIFI_HOME=/nifi-0.6.1
#ENV NIFI_HOME=/nifi-1.1.1.0-12
#ENV NIFI_HOME=/HDF-1.2.0.0/nifi
#ENV NIFI_HOME=/HDF-2.0.1.0/nifi
ENV NIFI_HOME=/HDF-2.1.2.0/nifi

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# web port
EXPOSE 8080

# listen port for web listening processor
EXPOSE 8081

# additional ports for user apps (bind them in a docker-compose.yml 'ports' section)
EXPOSE 10000
EXPOSE 10001
EXPOSE 10002
EXPOSE 10003
EXPOSE 10004

# expose for auth
EXPOSE 25001

ENV NIFI_JAVA_MINHEAP="-Xmx256m"
ENV NIFI_JAVA_MAXHEAP="-Xmx256m"

COPY login-identity-providers.xml $NIFI_HOME/conf/login-identity-providers.xml
COPY authority-providers.xml $NIFI_HOME/conf/authority-providers.xml
COPY authorized-users.xml $NIFI_HOME/conf/authorized-users.xml

WORKDIR $NIFI_HOME/bin
ADD ./run.sh .
RUN chmod +x ./run.sh
ENTRYPOINT ["./run.sh"]
