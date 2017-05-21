{%- from 'docker/settings.sls' import docker with context %}

docker:
  group.present:
    - gid: {{ docker.uid }}
  user.present:
    - uid: {{ docker.uid }}
    - gid: {{ docker.uid }}
    - groups:
      - docker
  pkgrepo.managed:
    - humanname: Docker Apt Repo
    - name: deb https://apt.dockerproject.org/repo ubuntu-{{ grains['oscodename'] }} main
    - dist: ubuntu-{{ grains['oscodename']  }}
    - file: /etc/apt/sources.list.d/docker.list
    - keyid: 58118E89F3A912897C070ADBF76221572C52609D
    - keyserver: keyserver.ubuntu.com

python-pip:
  pkg.installed

docker_update_pip:
  pip.installed:
    - name: pip
    - upgrade: true
    - require:
      - pkg: python-pip

{% if salt['pillar.get']('docker:config:dockercfg') %}
/root/.dockercfg:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents_pillar: docker:config:dockercfg
{% endif %}

docker-storage-dir:
  file.directory:
    - name: {{ docker.docker_storage_dir }}
    - makedirs: True

{% if grains['oscodename'] == 'trusty' %}
/etc/default/docker:
  file.managed:
    - source: salt://docker/templates/docker
    - template: jinja
    - context:
        docker_storage_dir: {{ docker.docker_storage_dir }}
        storage_driver: {{ docker.storage_driver }}
    - require:
        - file: docker-storage-dir
    - listen_in:
        - service: docker
{% endif %}

{% if grains['oscodename'] == 'xenial' %}
/etc/docker/daemon.json:
  file.managed:
    - source: salt://docker/templates/daemon.json
    - template: jinja
    - context:
        docker_storage_dir: {{ docker.docker_storage_dir }}
        storage_driver: {{ docker.storage_driver }}
        live_restore: {{ docker.live_restore }}
        max_size: {{ docker.max_size }}
    - module.run:
      - name: service.systemctl_reload
      - onchanges:
        - file: /etc/docker/daemon.json
    - require:
        - pkg: docker-engine
    - listen_in:
        - service: docker
{% endif %}

/etc/logrotate.d/docker:
  file.managed:
    - name: /etc/logrotate.d/docker
    - source: salt://docker/files/docker.logrotate
    - makedirs: True

docker-engine:
  pkg.installed:
    {% if docker.version == '1.12.6-0' %}
    - version: {{ docker.version }}~ubuntu-{{ grains['oscodename'] }}
    {% else %}
    - version: {{ docker.version }}~{{ grains['oscodename'] }}
    {% endif %}
    - listen_in:
        - service: docker
  group.present:
    - name: docker
    - addusers:
      {% set users = salt['user.list_users']() %}
      {% if 'newrelic' in users %}
        - newrelic
      {% endif %}
      {% if 'vagrant' in users %}
        - vagrant
      {% else %}
        - ubuntu
      {% endif %}
      {% if docker.group_members %}
        {% for member in docker.group_members %}
        - {{ member }}
        {% endfor %}
      {% endif %}

{% if 'newrelic' in users %}
newrelic-service-restart:
  service.running:
    - name: newrelic-sysmond
    - watch:
      - group: docker-engine
{% endif %}

docker-compose:
  pip.installed:
    - name: docker-compose=={{ docker.docker_compose_version }}
    - require:
        - pkg: python-pip

docker-py:
  pip.installed:
    - name: docker-py=={{ docker.docker_py_version }}
    - require:
        - pkg: python-pip

docker-service:
  service.running:
    - name: docker
    - enable: True
    - watch:
        - group: docker-engine
