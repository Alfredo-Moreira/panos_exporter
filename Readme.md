Panos_exporter
---
panos_exporter is an exporter to scape metrics from Paloalto NGFW api to get its current status and expose as prometheus metrics; and it can be used to montior its running statuss 


create a example configuration as yaml file:
```yaml
devices:
    10.36.48.15:
      username: user
      password: pass
```

then start panos_exporter via 
```sh
panos_exporter --config.file=panos_exporter.yaml 
```

then we can get the metrics via 
```
curl http://<panos_exporter host>:9654/panos?target=10.36.48.15

```

## Prometheus Configuration
add panos_exporter job config as following
  ```yaml
    - job_name: 'panos_exporter'
      metrics_path: /panos
      # scheme defaults to 'http'.

      static_configs:
      - targets:
        - 10.36.48.15
      relabel_configs:
        - source_labels: [__address__]
          target_label: __param_target
        - source_labels: [__param_target]
          target_label: instance
        - target_label: __address__
          replacement: localhost:9654  ### the address of the panos_exporter address
      metric_relabel_configs:
        - regex: 'rate'
          action: labeldrop
        - regex: 'id'
          action: labeldrop 

  ```
  > add label drop config as some metrics natively has `rate,id` lables
## API Commands for metrics
- global_counter_collector: `<show><counter><global></global></counter></show>`
- session_collector: `<show><session><info></info></session></show>`
- interface_collector: `<show><interface>all</interface></show>`
- interface_counter_collector: `<show><counter><interface>all</interface></counter></show>`
- system_resource_utilization_collector: `<show><system><resources></resources></system></show>`
- data_processor_resource_utilization_collector: `<show><running><resource-monitor><second><last>1</last></second></resource-monitor></running></show>`

## Support devices
- PA-3220(8.1.7)
