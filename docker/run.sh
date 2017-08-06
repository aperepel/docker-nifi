#!/bin/sh

splash() {
  echo 'Environment:'
  echo "NIFI_UI_BANNER_TEXT=$NIFI_UI_BANNER_TEXT"
}

configure_common() {
  #sed -i "s/nifi\.zookeeper\.connect\.string=.*$/nifi\.zookeeper\.connect\.string=${NIFI_ZOOKEEPER}/g" $HDF_HOME/conf/nifi.properties

  sed -i "s/nifi\.ui\.banner\.text=.*$/nifi.ui.banner.text=${NIFI_UI_BANNER_TEXT}/g" $HDF_HOME/conf/nifi.properties

  # configure heap size and GC use
  sed -i "s/#java\.arg\.13=-XX:+UseG1GC/java\.arg\.13=-XX:+UseG1GC/g" $HDF_HOME/conf/bootstrap.conf
  sed -i "s/java\.arg\.2=-Xms.*$/java\.arg\.2=$NIFI_JAVA_MINHEAP/g" $HDF_HOME/conf/bootstrap.conf
  sed -i "s/java\.arg\.3=-Xmx.*$/java\.arg\.3=$NIFI_JAVA_MAXHEAP/g" $HDF_HOME/conf/bootstrap.conf

  # add kerberos config
  sed -i 's/nifi\.kerberos\.krb5\.file=.*$/nifi\.kerberos\.krb5\.file=\/etc\/krb5.conf/g' $HDF_HOME/conf/nifi.properties
  sed -i 's/nifi\.security\.user\.credential\.cache\.duration=24 hours/nifi\.security\.user\.credential\.cache\.duration=2 hours/g' $HDF_HOME/conf/nifi.properties
  sed -i "s/<property name=\"Initial Admin Identity\"><\/property>/<property name=\"Initial Admin Identity\">${NIFI_ADMIN}<\/property>/g" $HDF_HOME/conf/authorizers.xml

  sed -i 's/nifi\.remote\.input\.http\.enabled=true/nifi\.remote\.input\.http\.enabled=false/g' $HDF_HOME/conf/nifi.properties

  
  # # configure for authentication
  #sed -i "s/nifi\.security\.user\.authority\.provider=.*$/nifi\.security\.user\.authority\.provider=cluster-ncm-provider/g" $HDF_HOME/conf/nifi.properties

  # # configure https to allow auth
  sed -i "s/nifi\.web\.http\.host=.*$/nifi.web.http.host=0.0.0.0/g" $HDF_HOME/conf/nifi.properties
  sed -i "s/nifi\.web\.http\.host=0\.0\.0\.0/nifi\.web\.http\.host=/g" $HDF_HOME/conf/nifi.properties
  sed -i "s/nifi\.web\.http\.port=8080/nifi\.web\.http\.port=/g" $HDF_HOME/conf/nifi.properties
  sed -i "s/nifi\.web\.https\.host=$/nifi\.web\.https\.host=0\.0\.0\.0/g" $HDF_HOME/conf/nifi.properties
  sed -i "s/nifi\.web\.https\.port=$/nifi\.web\.https\.port=8081/g" $HDF_HOME/conf/nifi.properties
  sed -i "s/nifi\.security\.keystore=$/nifi\.security\.keystore=\/etc\/security\/certs\/nifi\.jks/g" $HDF_HOME/conf/nifi.properties
  sed -i "s/nifi\.security\.keystoreType=.*$/nifi\.security\.keystoreType=JKS/g" $HDF_HOME/conf/nifi.properties
  sed -i "s/nifi\.security\.keystorePasswd=.*$/nifi\.security\.keystorePasswd=${NIFI_KEY_PASS}/g" $HDF_HOME/conf/nifi.properties
  sed -i "s/nifi\.security\.needClientAuth=.*$/nifi\.security\.needClientAuth=false/g" $HDF_HOME/conf/nifi.properties
  sed -i 's/nifi\.security\.user\.login\.identity\.provider=.*$/nifi\.security\.user\.login\.identity\.provider=kerberos-provider/g' $HDF_HOME/conf/nifi.properties
  sed -i "s/KRB_REALM/${KRB_REALM}/g" $HDF_HOME/conf/login-identity-providers.xml
}

splash
configure_common

exec keytool -genkeypair -alias nifiserver -keyalg RSA -keypass ${NIFI_KEY_PASS} -storepass ${NIFI_KEY_PASS} -keystore /etc/security/certs/nifi.jks -dname "CN=NIFI" -noprompt

# must be an exec so NiFi process replaces this script and receives signals
#exec ./bin/nifi.sh run
