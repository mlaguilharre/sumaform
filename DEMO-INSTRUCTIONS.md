Preparing
=========

Virtualization and image building
---------------------------------

* Add SLES 12 SP4 products
* Create HEAD SLE 12 Manager tools channel
    * name: `head-manager-tools-sle12`
    * summary: `HEAD SLE 12 manager tools`
    * repository url: http://mirror.tf.local/ibs/Devel:/Galaxy:/Manager:/Head:/SLE12-SUSE-Manager-Tools/images/repo/SLE-12-Manager-Tools-Beta-POOL-x86_64-Media1/
    * on demo-srv.tf.local, run `/usr/bin/spacewalk-repo-sync --channel head-manager-tools-sle12 --type yum`
* Create SLES 12 SP4 activation key
    * name: 1-SLE-12-SP4
    * Base channel: SLES-12-SP4-Pool for x86_64
    * Select all children channels
* Accept Salt keys for
    * demo-builder.tf.local
    * demo-git.tf.local
    * demo-min-kvm.tf.local
    * demo-minion1.tf.local
    * demo-minion2.tf.local
    * demo-minion3.tf.local
    * demo-minion4.tf.local
    * demo-minion5.tf.local
    * demo-minion6.tf.local

* Apply builder entitlement
    * On demo-builder.tf.local Details > properties page
        * Check OS Image Build Host
        * Click the Update button
    * Go to demo-builder.tf.local States > Highstate page
        * Apply the high state
* Create JeOS image
    * In Images > Profiles, click Create button
        * label: sles-12-jeos
        * type: kiwi
        * URL: http://demo-git.tf.local/jeos-12-manager#master
        * Activation key: 1-SLE-12-SP4
    * Build image on demo-builder.tf.local
* Apply Virtualization entitlement to demo-min-kvm.tf.local

Prepare Ubuntu channels
-----------------------

Follow these generic instructions by replacing the `${}` by the corresponding values in the table
below.

* Add channel
    * In Software > Manage > Channels click Create Channel
        * Name: `${name}`
        * Label: `${name}`
        * Parent Channel: ubuntu-18.04-pool for amd64
        * Architecture: AMD64 Debian
        * Summary: `${summary}` 
    * Go to the Repositories > Add/Remove tab
        * Click the Create Repository button
            * label: `${name}` 
            * url: `${url}` 
            * type: deb
            * Click the Create button
        * Change to Sync tab and click Sync Now button

| name                       | summary                            | url                                                                      |
| -------------------------- | ---------------------------------- | ------------------------------------------------------------------------ |
| ubuntu-18.04-main          | Ubuntu 18.04 main channel          | http://archive.ubuntu.com/ubuntu/dists/bionic/main/binary-amd64/         |
| ubuntu-18.04-main-update   | Ubuntu 18.04 main updates channel  | http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/binary-amd64/ |
| ubuntu-18.04-main-security | Ubuntu 18.04 main security channel | http://archive.ubuntu.com/ubuntu/dists/bionic/main/binary-amd64/         |

If using a sumaformed mirror of the Ubuntu repositories, replace the `http://archive.ubuntu.com`
parts of the URLs by `http://mirror.tf.local/archive.ubuntu.com`.

Now, create the Ubuntu activation key with the following input:

* 1-UBUNTU-KEY
* Base channel: ubuntu-18.04-pool for amd64
* Include all children channels

Create Ubuntu bootstrap repo

Demo Steps
==========

Image building
--------------

* Go to Images > Image List
* Show existing image infos
    * Highlight Profile, Channels
    * Show Packages
* Go to Images > Profiles
* Create a new profile:
    * label: pos-graphical
    * type: Kiwi
    * URL: copy/pasted
    * Activation key: SLES_12_SP3
* Launch build of pos-graphical profile
* Show image building status

Virtualization
--------------

* Go to Systems > Overview
* Click on demo-min-kvm.tf.local
* Highlight Virtualization Host entitlement
* Go to Virtualization tab
* Show VM actions
    * Start vm01
    * Show graphical console
    * Login in the console
    * Suspend vm01 and show
    * Resume vm01 and show
    * Shutdown vm01
    * Close the console
    * Edit vm01
        * vCPU: 2
        * new disk (default values)
        * new vnet
        * VNC
    * Start vm01 and login in it
        * ip a
        * hwinfo –disk
* Create Guest
    * name: vm2
    * Memory: 512MB
    * Disk URL: copy from os-images tab
* Talk about Salt virt
* Wait for new VM to start and display console

Ubuntu minions
--------------

* SSH on demo-min-ubuntu.tf.local
* wget http://demo-srv.tf.local/pub/bootstrap/bootstrap.sh
* Edit it to set the activation key to 1-UBUNTU-KEY
* `bash ./bootstrap.sh`
* Accept the Salt key
* Show the registered system

Monitoring
----------

* Show the server dashboard
* Check the `Monitoring` box in `demo-git.tf.local` properties and submit
* Apply the hightstate on `demo-git.tf.local`
* Show the client systems dashboard

Opened tabs
===========

* https://demo-srv.tf.local
* https://github.com/SUSE/manager-build-profiles/tree/master/OSImage
* https://demo-srv.tf.local/os-images/1/
* https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.virt.html
* https://docs.saltstack.com/en/latest/ref/states/all/salt.states.virt.html
* http://demo-grafana.tf.local

Clean up
========

* Delete vm02
* Shutdown vm01
* Remove pos-graphical image build and profile
* on demo-srv.tf.local, only leave the following image in /srv/www/os-images/1
    * SLES12-SP2-JeOS-for-kvm-and-xen.x86_64-1.3.0-build67.qcow2 
* Delete demo-min-ubuntu.tf.local systemA

Content Staging (Batch Prefetching)
========================
* On minion[1-6]
* scp demo-srv:/srv/www/htdocs/pub/sle12-gpg-pubkey-39db7c82.key .
* Depuis le host for i in {2..6}; do ssh minion$i "rpm --import sle12-gpg-pubkey-39db7c82.key"; done
* Enable content staging GUI >Home>My Organization>Configuration
* /etc/rhn/rhn.conf:#java.salt_content_staging_advance = 1
* /etc/rhn/rhn.conf:#java.salt_content_staging_window = 1
* spacewalk-service restart
* In UI upgrade cron rpm for minion[1-6]
* for i in {1..6}; do ssh minion$i "find /var/ -name "*.rpm" -exec ls -al '{}' \;"; done



Salt Batching
===============
* Adjust java.salt_batch_size to 2 in rhn.conf
* spacewalk-service restart
* Salt remote command in GUI


Alternate Endpoint Download
==========================
*Create /srv/pillar/top.sls
base:
  '*':
    - pkg_download_points

*Create /srv/pillar/pkg_download_points.sls
{% if grains['fqdn'] == 'demo-minion1.tf.local' %}
      pkg_download_point_protocol: http
      pkg_download_point_host: alternate.name.com
      pkg_download_point_port: 444
{% endif %}

*salt 'demo-minion1.tf.local' saltutil.refresh_pillar
*salt 'demo-minion1.tf.local' state.apply channels

 
Libvirt Network Configuration
==========================


<network connections='3'>
  <name>default</name>
  <uuid>d6c95a31-16a2-473a-b8cd-7ad2fe2dd855</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:cd:49:6b'/>
  <dns>
    <host ip='192.168.122.100'>
      <hostname>minion6.local</hostname>
    </host>
    <host ip='192.168.122.99'>
      <hostname>minion5.local</hostname>
    </host>
    <host ip='192.168.122.98'>
      <hostname>minion4.local</hostname>
    </host>
    <host ip='192.168.122.97'>
      <hostname>minion3.local</hostname>
    </host>
    <host ip='192.168.122.96'>
      <hostname>minion2.tf.local</hostname>
    </host>
    <host ip='192.168.122.95'>
      <hostname>minion1.tf.local</hostname>
    </host>
    <host ip='192.168.122.94'>
      <hostname>demo-srv.tf.local</hostname>
    </host>
    <host ip='192.168.122.93'>
      <hostname>demo-min-ubuntu.tf.local</hostname>
    </host>
    <host ip='192.168.122.92'>
      <hostname>demo-min-kvm.tf.local</hostname>
    </host>
    <host ip='192.168.122.91'>
      <hostname>demo-git.tf.local</hostname>
    </host>
    <host ip='192.168.122.90'>
      <hostname>demo-builder.tf.local</hostname>
    </host>
    <host ip='192.168.122.89'>
      <hostname>demo-grafana.tf.local</hostname>
    </host>
  </dns>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
      <host mac='2a:c3:a7:a6:de:c0' name='minion1' ip='192.168.122.95'/>
      <host mac='2a:c3:a7:a6:de:c1' name='minion2' ip='192.168.122.96'/>
      <host mac='2a:c3:a7:a6:de:c2' name='minion3' ip='192.168.122.97'/>
      <host mac='2a:c3:a7:a6:de:c3' name='minion4' ip='192.168.122.98'/>
      <host mac='2a:c3:a7:a6:de:c4' name='minion5' ip='192.168.122.99'/>
      <host mac='2a:c3:a7:a6:de:c5' name='minion6' ip='192.168.122.100'/>
      <host mac='2a:c3:a7:a6:de:bf' name='demo-srv' ip='192.168.122.94'/>
      <host mac='2a:c3:a7:a6:de:be' name='demo-min-ubuntu' ip='192.168.122.93'/>
      <host mac='2a:c3:a7:a6:de:bd' name='demo-min-kvm' ip='192.168.122.92'/>
      <host mac='2a:c3:a7:a6:de:bc' name='demo-git' ip='192.168.122.91'/>
      <host mac='2a:c3:a7:a6:de:bb' name='demo-builder' ip='192.168.122.90'/>
      <host mac='2a:c3:a7:a6:de:ba' name='demo-grafana' ip='192.168.122.89'/>
    </dhcp>
  </ip>
</network>
