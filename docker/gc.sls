{%- from 'docker/settings.sls' import docker with context %}

etc-docker-gc-exclude:
  file.managed:
    - name: /etc/docker-gc-exclude
    - source: salt://docker/templates/docker-gc-exclude
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        gc_exclude: {{ docker.gc_exclude }}

docker-gc:
  pkg.installed:
    - version: 2:0.1.0

/etc/cron.hourly/docker-gc:
  file.absent

/usr/sbin/docker-gc:
  cron.present:
    - identifier: DOCKERGC
    - user: root
    - minute: '*/15'

GRACE_PERIOD_SECONDS:
  cron.env_present:
    - value: 300
    - user: root
