**{{github.workflow}}: {{github.repository}}**

Status: **{{status_label}}**
{{#if package_version}}
Version: **{{package_version}}**
{{/if}}
Ref: {{github.ref_name}}
Triggered by: {{github.actor}}

[Open workflow run]({{url github.run_url}})
{{#if pub_dev_url}}
[Open published version on pub.dev]({{url pub_dev_url}})
{{/if}}
