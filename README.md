# dbserver

PostgreSQL + TimescaleDB Kubernetes manifests for the `apps` namespace.

## Deploy

All Kubernetes commands should run from workstation `192.168.55.148`.

Mirror the TimescaleDB image to the internal registry:

```powershell
plink -ssh -batch -l ubuntu -pw ubuntu 192.168.55.148 "podman pull timescale/timescaledb:2.27.1-pg16 && podman tag timescale/timescaledb:2.27.1-pg16 192.168.55.148:5000/timescale/timescaledb:2.27.1-pg16 && podman push 192.168.55.148:5000/timescale/timescaledb:2.27.1-pg16"
```

Create the database secret:

```powershell
plink -ssh -batch -l ubuntu -pw ubuntu 192.168.55.148 "kubectl create namespace apps --dry-run=client -o yaml | kubectl apply -f -"
plink -ssh -batch -l ubuntu -pw ubuntu 192.168.55.148 "kubectl create secret generic timescaledb-secret --namespace apps `
  --from-literal=POSTGRES_USER=postgres `
  --from-literal=POSTGRES_PASSWORD='change-this-password' `
  --from-literal=POSTGRES_DB=appdb `
  --dry-run=client -o yaml | kubectl apply -f -"
```

Apply the manifests:

```powershell
plink -ssh -batch -l ubuntu -pw ubuntu 192.168.55.148 "kubectl apply -k deploy/k8s"
plink -ssh -batch -l ubuntu -pw ubuntu 192.168.55.148 "kubectl apply -f deploy/argocd/application.yaml"
```

Check rollout status:

```powershell
plink -ssh -batch -l ubuntu -pw ubuntu 192.168.55.148 "kubectl -n apps rollout status statefulset/timescaledb"
plink -ssh -batch -l ubuntu -pw ubuntu 192.168.55.148 "kubectl -n apps get statefulset,pod,svc,pvc"
```

### GitHub Actions

The workflow at `.github/workflows/build-deploy.yml` mirrors the image, injects the Secret from GitHub Secrets, applies the Argo CD Application, and deploys the manifests.

Add these repository or environment secrets:

```text
POSTGRES_USER     database username
POSTGRES_PASSWORD database password
POSTGRES_DB       database name
```

Connect from another pod in the same cluster with:

```text
timescaledb.apps.svc.cluster.local:5432
```

## Notes

- The external image is mirrored to `192.168.55.148:5000/timescale/timescaledb:2.27.1-pg16`.
- Storage defaults to a `20Gi` `ReadWriteOnce` PVC using `nfs-client`.
- `CREATE EXTENSION IF NOT EXISTS timescaledb;` runs on first database initialization.
- Do not commit a real password. Use `deploy/secret.example.yaml` only as a template.
