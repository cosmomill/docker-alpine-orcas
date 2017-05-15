#!/bin/bash

# stop on errors
set -e

# check whether Orcas configuration already exists
if [ -d "$ORCAS_HOME/${SCHEMA,,}" ]; then
	echo "Orcas configuration found."
else
	# create tnsnames.ora
	mkdir -p $ORACLE_HOME/network/admin
	echo "$SCHEMA =
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = $DATABASE_HOSTNAME)(PORT = $DATABASE_PORT))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = $DATABASE_SID)
  )
)" > $ORACLE_HOME/network/admin/tnsnames.ora

	# create project folder
	mkdir -p $ORCAS_HOME/${SCHEMA,,}/schema_sync
	cp -r /opt/orcas/examples/schema_sync/distribution $ORCAS_HOME/${SCHEMA,,}/schema_sync/

	echo "database              =$SCHEMA
jdbc_host             =$DATABASE_HOSTNAME
jdbc_sid              =$DATABASE_SID
jdbc_port             =$DATABASE_PORT
jdbc_url              =jdbc:oracle:thin:@\${jdbc_host}:\${jdbc_port}:\${jdbc_sid}
username_schemaowner  =$SCHEMA_USERNAME
password_schemaowner  =$SCHEMA_PASSWORD" > $ORCAS_HOME/${SCHEMA,,}/schema_sync/distribution/my_location/location.properties

	cp $ORCAS_HOME/${SCHEMA,,}/schema_sync/distribution/ant_default_include.xml $ORCAS_HOME/${SCHEMA,,}/schema_sync/distribution/build.xml

	sed -i "s/<project name=\"ant_default_include\">/<project name=\"${SCHEMA,,}\">/g" $ORCAS_HOME/${SCHEMA,,}/schema_sync/distribution/build.xml
	sed -i "s|\${distributiondir}/../../../../bin_\${ant.project.name}|\${distributiondir}/../../bin_\${ant.project.name}|g" $ORCAS_HOME/${SCHEMA,,}/schema_sync/distribution/build.xml
	sed -i "s|\${distributiondir}/../../../orcas_core|\${distributiondir}/../../../../../opt/orcas/orcas_core|g" $ORCAS_HOME/${SCHEMA,,}/schema_sync/distribution/build.xml
	sed -i "/<\/project>/d" $ORCAS_HOME/${SCHEMA,,}/schema_sync/distribution/build.xml

	echo '  <target name="orcas_initialize" depends="show_location">
    <orcas_initialize user="${username_schemaowner}" password="${password_schemaowner}" tnsname="${database}" jdbcurl="${jdbc_url}" orcasinternalinstalldb="false" prebuildmode="none" prebuildfile="/opt/prebuild.zip"/>
  </target>

  <target name="extract" depends="show_location,orcas_initialize">
    <orcas_extract outputfolder="${distributiondir}/../../db/tables" user="${username_schemaowner}" password="${password_schemaowner}" tnsname="${database}" jdbcurl="${jdbc_url}" />
    <orcas_extract_replaceables outputfolder="${distributiondir}/../../db/replaceables" user="${username_schemaowner}" password="${password_schemaowner}" tnsname="${database}" jdbcurl="${jdbc_url}" />
  </target>

  <target name="deploy" depends="show_location,orcas_initialize">
    <delete dir="${binrundir}/log" />
    <orcas_execute_statics createmissingfkindexes="false" scriptfolder="${distributiondir}/../../db/tables" spoolfolder="${binrundir}/log" logname="tables" dropmode="false" user="${username_schemaowner}" password="${password_schemaowner}" tnsname="${database}" jdbcurl="${jdbc_url}" />
    <orcas_execute_scripts scriptfolder="${distributiondir}/../../db/replaceables" scriptfolderrecursive="true" spoolfolder="${binrundir}/log" logname="sync_replaceables" user="${username_schemaowner}" password="${password_schemaowner}" tnsname="${database}" jdbcurl="${jdbc_url}" />
    <orcas_compile_db_objects user="${username_schemaowner}" password="${password_schemaowner}" tnsname="${database}" jdbcurl="${jdbc_url}" />
  </target>

</project>' >> $ORCAS_HOME/${SCHEMA,,}/schema_sync/distribution/build.xml

	cd $ORCAS_HOME/${SCHEMA,,}/schema_sync/distribution
	ant extract

fi;

cd $ORCAS_HOME/${SCHEMA,,}/schema_sync/distribution
ant extract

exec /bin/bash
