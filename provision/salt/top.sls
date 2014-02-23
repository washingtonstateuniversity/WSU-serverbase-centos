{%- set isLocal = "false" -%}
{% for host,ip in salt['mine.get']('*', 'network.ip_addrs').items() -%}
    {% if ip|replace("10.255.255", "LOCAL").split('LOCAL').count() == 2  %}
        {%- set isLocal = "true" -%}
    {%- endif %}
{%- endfor %}
base:
{% if 'serverbase' in salt['mine.get']('*', 'roles').items() %}
    - serverbase
{% endif %}
    - finalize.restart