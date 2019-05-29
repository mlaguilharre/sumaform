{% if grains.get('role') == 'mirror' %}

# We need that repository for apt-mirror
suse_manager_devel_repo:
  file.managed:
    - name: /etc/zypp/repos.d/systemsmanagement-sumaform-tools.repo
    - source: repos/repos.d/systemsmanagement-sumaform-tools.repo
    - template: jinja

{% endif %}

