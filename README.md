# Building

docker build -t local/prometheus-exporter .

# Running

This is intended to be run as a sidecar alongside Varnish, in e.g., a
Kubernetes pod. They will need to share a varnish working directory,
which you can accomplish by mounting a volume in both
containers. Here's an example deployment:

```
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: proxy
spec:
  replicas: 1
  revisionHistoryLimit: 2
  strategy:
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 0
  template:
    metadata:
      labels:
        name: proxy
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9131"
    spec:

      volumes:
      - name: config
        configMap:
          name: proxy-config
      - name: varlibvarnish
        emptyDir: {}

      containers:
      - name: varnish
        image: varnish:6.2
        imagePullPolicy: IfNotPresent
        env:
        - name: VSM_NOPID
          value: "true"
        resources:
          requests:
            memory: "250Mi"
        args:
        - varnishd
        - -F
        - -s malloc,200M
        - -f/etc/varnish/default.vcl
        volumeMounts:
        - name: config
          mountPath: /etc/varnish/default.vcl
          subPath: default.vcl
        - name: varlibvarnish
          mountPath: /var/lib/varnish
        ports:
        - name: http
          containerPort: 80

      - name: exporter
        image: prom-export
        imagePullPolicy: IfNotPresent
        env:
        - name: VSM_NOPID
          value: "true"
        ports:
        - name: metrics
          containerPort: 9131
        volumeMounts:
        - name: varlibvarnish
          mountPath: /var/lib/varnish
```
