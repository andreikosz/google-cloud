apiVersion: apps/v1
kind: Deployment
metadata:
  name: gradle-spring-boot
  labels:
    app: gradle-spring-boot
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gradle-spring-boot
  template:
    metadata:
      labels:
        app: gradle-spring-boot
    spec:
      containers:
      - name: gradle-spring-boot
        image: gcr.io/GOOGLE_CLOUD_PROJECT/gradle-spring-boot:COMMIT_SHA
        ports:
        - containerPort: 8080
---
kind: Service
apiVersion: v1
metadata:
  name: gradle-spring-boot
spec:
  selector:
    app: gradle-spring-boot
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer