#!/bin/bash

splash() {
  echo 'Environment:'
  echo "NIFI_UI_BANNER_TEXT=$NIFI_UI_BANNER_TEXT"
}

configure_common() {
  sed -i 's/\.\/flowfile_repository/\/flowrepo/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/content_repository/\/contentrepo/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/conf\/flow\.xml\.gz/\/flowconf\/flow.xml.gz/' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/conf\/archive/\/flowconf\/archive/' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/database_repository/\/databaserepo/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/provenance_repository/\/provenancerepo/g' $NIFI_HOME/conf/nifi.properties

  sed -i "s/nifi\.ui\.banner\.text=.*$/nifi.ui.banner.text=${NIFI_UI_BANNER_TEXT}/g" $NIFI_HOME/conf/nifi.properties

  # configure heap size and GC use
  sed -i "s/#java\.arg\.13=-XX:+UseG1GC/java\.arg\.13=-XX:+UseG1GC/g" $NIFI_HOME/conf/bootstrap.conf
  sed -i "s/java\.arg\.2=-Xms.*$/java\.arg\.2=$NIFI_JAVA_MINHEAP/g" $NIFI_HOME/conf/bootstrap.conf
  sed -i "s/java\.arg\.3=-Xmx.*$/java\.arg\.3=$NIFI_JAVA_MAXHEAP/g" $NIFI_HOME/conf/bootstrap.conf

  # add kerberos config
  sed -i 's/nifi\.kerberos\.krb5\.file=.*$/nifi\.kerberos\.krb5\.file=\/etc\/krb5.conf/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/nifi\.security\.user\.credential\.cache\.duration=24 hours/nifi\.security\.user\.credential\.cache\.duration=12 hours/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/nifi\.security\.user\.login\.identity\.provider=.*$/nifi\.security\.user\.login\.identity\.provider=kerberos-provider/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/KRB_REALM/${KRB_REALM}/g' $NIFI_HOME/conf/login-identity-providers.xml
}

configure_site2site() {
  # configure the receiving end of site2site
  sed -i "s/nifi\.remote\.input\.socket\.host=.*$/nifi.remote.input.socket.host=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.remote\.input\.socket\.port=.*$/nifi.remote.input.socket.port=12345/g" $NIFI_HOME/conf/nifi.properties
  # unsecure for now so we don't complicate the setup with certificates
  sed -i "s/nifi\.remote\.input\.secure=true/nifi.remote.input.secure=false/g" $NIFI_HOME/conf/nifi.properties
}

configure_cluster_node() {
  # can't set to 0.0.0.0, as this address is then sent verbatim to NCM, which, in turn
  # does not resolve it back to the node. If it's set to the ${HOSTNAME}, the cluster works,
  # but the node's web ui is not accessible on the external network
  #sed -i "s/nifi\.web\.http\.host=/nifi.web.http.host=0.0.0.0/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.web\.http\.host=.*$/nifi.web.http.host=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.is\.node=false/nifi.cluster.is.node=true/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.node\.address=.*$/nifi.cluster.node.address=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.node\.protocol\.port=.*$/nifi.cluster.node.protocol.port=12346/g" $NIFI_HOME/conf/nifi.properties
  # the following properties point to the NCM - note we are using the network alias (implicitly created by docker-compose)
  sed -i "s/nifi\.cluster\.node\.unicast\.manager\.address=.*$/nifi.cluster.node.unicast.manager.address=ncm/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.node\.unicast\.manager\.protocol\.port=.*$/nifi.cluster.node.unicast.manager.protocol.port=20001/g" $NIFI_HOME/conf/nifi.properties

  # configure for authentication
  sed -i "s/nifi\.security\.user\.authority\.provider=.*$/nifi\.security\.user\.authority\.provider=cluster-node-provider/g" $NIFI_HOME/conf/nifi.properties
}

configure_cluster_manager() {
  sed -i "s/nifi\.web\.http\.host=.*$/nifi.web.http.host=0.0.0.0/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.is\.manager=false/nifi.cluster.is.manager=true/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.manager\.address=.*$/nifi.cluster.manager.address=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.manager\.protocol\.port=.*$/nifi.cluster.manager.protocol.port=20001/g" $NIFI_HOME/conf/nifi.properties

  # configure for authentication
  sed -i "s/nifi\.security\.user\.authority\.provider=.*$/nifi\.security\.user\.authority\.provider=cluster-ncm-provider/g" $NIFI_HOME/conf/nifi.properties

  # configure https to allow auth
  sed -i "s/nifi\.web\.http\.host=0\.0\.0\.0/nifi\.web\.http\.host=/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.web\.http\.port=8080/nifi\.web\.http\.port=/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.web\.https\.host=$/nifi\.web\.https\.host=0\.0\.0\.0/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.web\.https\.port=$/nifi\.web\.https\.port=8080/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.security\.keystore=$/nifi\.security\.keystore=\/etc\/security\/nifi\/certs\/nifi\.pfx/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.security\.keystoreType=.*$/nifi\.security\.keystoreType=PKCS12/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.security\.needClientAuth=.*$/nifi\.security\.needClientAuth=false/g" $NIFI_HOME/conf/nifi.properties
}

splash
configure_common

# we don't configure acquisition node to serve site-to-site requests,
# the node initiates push/pull only

if [ "$NIFI_INSTANCE_ROLE" == "node" ]; then
  configure_site2site
fi

if [ "$NIFI_INSTANCE_ROLE" == "cluster-node" ]; then
  configure_site2site
  configure_cluster_node
fi

if [ "$NIFI_INSTANCE_ROLE" == "cluster-manager" ]; then
  configure_site2site
  configure_cluster_manager
fi

# must be an exec so NiFi process replaces this script and receives signals
exec ./nifi.sh run