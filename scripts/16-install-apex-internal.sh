#!/bin/bash

# Run as oracle user

set -eu

cd $APEX_HOME

echo "Installing APEX"
sqlplus / as sysdba << EOF
  alter session set container = ${DB_SERVICENAME};

  -- Install APEX
  @apexins.sql SYSAUX SYSAUX TEMP /i/

  -- APEX REST configuration
  @apex_rest_config_core.sql @ "${ORACLE_PASSWORD}" "${ORACLE_PASSWORD}"

  -- Required for ORDS install
  alter user $APEX_DB_USER         identified by "${ORACLE_PASSWORD}" account unlock;
  alter user FLOWS_FILES           identified by "${ORACLE_PASSWORD}" account unlock;
  alter user APEX_PUBLIC_USER      identified by "${ORACLE_PASSWORD}" account unlock;
  alter user APEX_REST_PUBLIC_USER identified by "${ORACLE_PASSWORD}" account unlock;
  alter user APEX_LISTENER         identified by "${ORACLE_PASSWORD}" account unlock;


  -- Network ACL
  prompt Setup Network ACL
  begin
    for c1 in (
      select schema
      from sys.dba_registry
      where comp_id = 'APEX'
    ) loop
      sys.dbms_network_acl_admin.append_host_ace(
        host => '*'
        , ace => xs\$ace_type(
            privilege_list => xs\$name_list('connect')
            , principal_name => c1.schema
            , principal_type => xs_acl.ptype_db
        )
      );
    end loop;
    commit;
  end;
  /

  -- Setup APEX Admin account
  prompt Setup APEX Admin account
  begin
    apex_util.set_workspace(p_workspace => 'internal');
    apex_util.create_user(
      p_user_name => 'ADMIN'
      , p_email_address => '${APEX_ADMIN_EMAIL}'
      , p_web_password => '${APEX_ADMIN_PWD}'
      , p_developer_privs => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL'
      , p_change_password_on_first_use => 'N'
    );
    commit;
  end;
  /

  -- PT-BR for APEX
  @./builder/pt-br/load_pt-br.sql

EOF