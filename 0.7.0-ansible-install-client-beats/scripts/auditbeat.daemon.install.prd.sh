#!/bin/bash
yum update -y && sudo yum install curl -y
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
curl -L -O https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-7.5.2-x86_64.rpm
rpm -vi auditbeat-7.5.2-x86_64.rpm
mkdir /var/log/auditbeat

cat <<EOF > /etc/auditbeat/auditbeat.yml
###################### Auditbeat Configuration Example #########################

# This is an example configuration file highlighting only the most common
# options. The auditbeat.reference.yml file from the same directory contains all
# the supported options with more comments. You can use it as a reference.
#
# You can find the full configuration reference here:
# https://www.elastic.co/guide/en/beats/auditbeat/index.html

#==========================  Modules configuration =============================
auditbeat.modules:

- module: auditd
  audit_rules: |
    -w /etc/group -p wa -k identity
    -w /etc/passwd -p wa -k identity
    -w /etc/gshadow -p wa -k identity
    -w /etc/shadow -p wa -k identity
    -w /etc/security/opasswd -p wa -k identity
    -a exit,always -F path=/etc/passwd -F perm=r -F uid=33 -k www-passwd-read
    -a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -k access
    -a always,exit -F arch=b64 -S socket -F a0=2 -k socket
    -a always,exit -F arch=b64 -S socket -F a0=10 -k socket
    -a always,exit -F dir=/home -F uid=0 -F auid>=1000 -F auid!=4294967295 -C auid!=obj_uid -F key=power-abuse
    -a always,exit -S execve
    -a always,exit -F arch=b64 -S setuid -F a0=0 -F exe=/usr/bin/su -F key=elevated-privs
    -a always,exit -F arch=b32 -S setuid -F a0=0 -F exe=/usr/bin/su -F key=elevated-privs
    -a always,exit -F arch=b64 -S setresuid -F a0=0 -F exe=/usr/bin/sudo -F key=elevated-privs
    -a always,exit -F arch=b32 -S setresuid -F a0=0 -F exe=/usr/bin/sudo -F key=elevated-privs
    -a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -F key=elevated-privs
    -a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -F key=elevated-privs

- module: file_integrity
  paths:
  - /bin
  - /usr/bin
  - /sbin
  - /usr/sbin
  - /etc

- module: system
  datasets:
    - host
    - login
    - package
    - process
    - socket
    - user
  period: 10s
  state.period: 1m
  user.detect_password_changes: true
  login.wtmp_file_pattern: /var/log/wtmp*
  login.btmp_file_pattern: /var/log/btmp*
#================================ Dashboard ===================================
setup.dashboard.enabled: true


#==================== Elasticsearch template setting ==========================
setup.ilm.check_exists: false
setup.template.settings:
  index.number_of_shards: 1
  #index.codec: best_compression
  #_source.enabled: false

#================================ General =====================================

# The name of the shipper that publishes the network data. It can be used to group
# all the transactions sent by a single shipper in the web interface.
#name:

# The tags of the shipper are included in their own field with each
# transaction published.
#tags: ["service-X", "web-tier"]

# Optional fields that you can specify to add additional information to the
# output.
#fields:
#  env: staging

#================================ Outputs =====================================

# Configure what outputs to use when sending the data collected by the beat.
# Multiple outputs may be used.

#-------------------------- Elasticsearch output ------------------------------
output.elasticsearch:
  hosts: ["esingest.domain.com.br:9200"]
  protocol: "http"
  username: "beats_user"
  password: "GyQSoXW9w0pBnV"
  ilm.enabled: true
  ilm.rollover_alias: "auditbeat"
  ilm.pattern: "{now/d}-000001"

# =================================== Kibana ===================================
setup.kibana:
  hosts: "kbn.domain.com.br:5601"

#----------------------------- Logstash output --------------------------------
#output.logstash:
  # The Logstash hosts
  #hosts: ["localhost:5044"]

  # Optional SSL. By default is off.
  # List of root certificates for HTTPS server verifications
  #ssl.certificate_authorities: ["/etc/pki/root/ca.pem"]

  # Certificate for SSL client authentication
  #ssl.certificate: "/etc/pki/client/cert.pem"

  # Client Certificate Key
  #ssl.key: "/etc/pki/client/cert.key"

# ================================= Processors =================================

# Configure processors to enhance or manipulate events generated by the beat.

processors:
  - add_host_metadata: ~

#================================ Logging =====================================

# Sets log level. The default log level is info.
# Available log levels are: critical, error, warning, info, debug
#logging.level: debug
logging.to_files: true
logging.files:
  path: /var/log/auditbeat

# At debug level, you can selectively enable logging only for some components.
# To enable all selectors use ["*"]. Examples of other selectors are "beat",
# "publish", "service".
#logging.selectors: ["*"]

EOF

systemctl enable auditbeat && sudo systemctl start auditbeat
auditbeat setup

exit 0