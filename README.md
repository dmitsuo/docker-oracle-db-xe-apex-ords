# Oracle Database XE 18c Docker Container with APEX 22.2 and ORDS 22.4
This GitHub repository provides a Docker-based solution for setting up a local development environment with Oracle XE 18c database, Oracle Application Express (APEX), and Oracle REST Data Services (ORDS). With this repository, you can easily and quickly set up a fully functional development environment that includes all the necessary components for building and deploying Oracle-based applications.

## Requirements
- **GNU/Linux** operation system (any distro is fine)
- Docker 17+
- Bash shell 4.0+
- CURL / TAR / GZIP / UNZIP
- RAM: 3GB available
- Storage: 8GB of free disk space on <code>/var</code> partition
- Internet access in order to download installation packages and Docker base images

## Software versions
The following software versions will be installed by this repository as Docker containers:
- [Oracle Database Express Edition (XE) 18c](https://www.oracle.com/database/technologies/xe18c-downloads.html)
- [Oracle Application Express (APEX) 22.2](https://www.oracle.com/tools/downloads/apex-downloads)
- [Oracle REST Data Services (ORDS) 22.4.4](https://www.oracle.com/database/sqldeveloper/technologies/db-actions/download)

## WARNING
This solution is intended to be used **ONLY IN LOCAL TESTING AND DEVELOPMENT ENVIRONMENTS**.<br/>
**PLEASE DO NOT USE THE IMAGES AND CONTAINERS DEFINED IN THIS REPOSITORY IN ANY PRODUCTION ENVIRONMENT, NOR MAKE THEM AVAILABLE THROUGH THE INTERNET**, as issues related to information security and data protection have not been addressed in this repository.

## How to use
1. Clone this repository to your local machine with the following command


```bash
git clone https://github.com/dmitsuo/docker-oracle-db-xe-apex-ords.git
```

2. Navigate to the root directory of the cloned repository with the following command

```bash
cd docker-oracle-db-xe-apex-ords
```

3. Check whether you need to modify any of the variables within the <b>[scripts/00-setenv.sh](/scripts/00-setenv.sh)</b> parameter file, or whether the default values are sufficient.

4. Give execution permission to <b><code>*.sh</code></b> bash scripts with the following command

```bash
set -R +x *.sh
```

5. Call installation script with admin privileges with the following command

```bash
sudo ./000-install-apex-ords.sh
```

This script will do the following:
  - Download Java JRE 11, APEX 22.2 and ORDS 22.4
  - Download [gvenzl/oracle-xe](https://github.com/gvenzl/oci-oracle-xe) Oracle XE 18c Docker image and run it as a container
  - Execute all required SQL scripts to install APEX 22.2
  - Install and configure ORDS 22.4 to run as a web application inside an Apache Tomcat 9.x Docker container  

It will take from 15 to 30 minutes, depending on your machine and internet speed.<br/><br/>
<b>ATTENTION</b>: You will need to run this "<b><code>000-install-apex-ords.sh</code></b>" script only once.

6. Execute the following command with admin privileges to start Oracle Database XE 18c with installed APEX and an ORDS server as a Docker container:

```bash
sudo ./010-start-db-ords.sh
```

7. Go to APEX Admin page, provided by ORDS server in the following URL
```bash
http://localhost:20231/ords
```

In the above URL, "<b>20231</b>" is the default ORDS Server HTTP port, defined in the "<code><b>ORDS_CONTAINER_HTTP_PORT</b></code>" variable, inside <b>[scripts/00-setenv.sh](/scripts/00-setenv.sh)</b> file.

This will lead you to the following screen

![APEX admin login](/img/apex_admin_login.png)

The username is "<b>ADMIN</b>" and the password is defined in the "<code><b>APEX_ADMIN_PWD</b></code>" variable, inside <b>[scripts/00-setenv.sh](/scripts/00-setenv.sh)</b> file.

## Credits
This solution was heavily based on the following remarkable works:
  - https://github.com/gvenzl/oci-oracle-xe
  - https://github.com/fuzziebrain/docker-apex-stack/blob/master/scripts/setup/package/installApex.sh
  - https://joelkallman.blogspot.com/2017/05/apex-and-ords-up-and-running-in2-steps.html
