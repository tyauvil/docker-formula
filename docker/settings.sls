{% set p    = pillar.get('docker', {}) %}
{% set pc   = p.get('config', {}) %}
{% set g    = grains.get('docker', {}) %}
{% set gc   = g.get('config', {}) %}

{%- set docker = {} %}
{%- do docker.update({
  'version'                : p.get('version', '1.12.1-0'),
  'docker_py_version'      : p.get('docker_py_version', '1.10.6'),
  'docker_compose_version' : p.get('docker_compose_version', '1.9.0'),
  'gc_exclude'             : p.get('gc_exclude', ''),
  'dockercfg'              : gc.get('dockercfg', pc.get('dockercfg', '')),
  'docker_storage_dir'     : pc.get('docker_storage_dir', '/data/docker'),
  'storage_driver'         : gc.get('storage_driver', pc.get('storage_driver','aufs')),
  'live_restore'           : p.get('live_restore', 'false'),
  'uid'                    : pc.get('uid','5002'),
  'group_members'          : pc.get('group_members', []),
  'max_size'               : pc.get('max_size', '100m')
  }) %}
