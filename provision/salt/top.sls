{% set vars = {'isLocal': False} %}
{% if vars.update({'ip': ''}) %} {% endif %}
{% if vars.update({'isLocal': salt['cmd.run']('echo $SERVER_TYPE') }) %} {% endif %}

base:
  '*':
{% if vars.isLocal %}
    - systemcheck
{% else %}
    - os.centos
    - users
{% if 'serverbase' in grains.get('roles') %}
    - serverbase
{% endif %}
{% if 'email' in grains.get('roles') %}
    - email
{% endif %}
{% if 'database' in grains.get('roles') %}
    - database
{% endif %}
{% if 'ssl' in grains.get('roles') %}
    - ssl
{% endif %}
{% if 'web' in grains.get('roles') %}
    - web
{% endif %}
    - node
{% if 'webcaching' in grains.get('roles') %}
    - caching
{% endif %}
{% if 'java' in grains.get('roles') %}
    - java
{% endif %}
{% if vars.isLocal %}
    - env.development
{% else %}
    - env.production
{%- endif %}
{% if 'security' in grains.get('roles') %}
    - security
{% endif %}
    - cron
    - finalize.restart