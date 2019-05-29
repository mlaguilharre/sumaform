{% if grains.get('role') == 'mirror' %}

# We need that repository for apt-mirror
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/cbosdonnat.repo
    - source: salt://repos/repos.d/cbosdonnat.repo
    - template: jinja

{% endif %}

