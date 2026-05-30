# dbserver

MarketFlow database infrastructure for PostgreSQL + TimescaleDB.

## Kubernetes

Namespace: `marketflow`

Service:

```text
marketflow-db.marketflow.svc.cluster.local:5432
```

Default database:

```text
DATABASE_HOST=marketflow-db.marketflow.svc.cluster.local
DATABASE_PORT=5432
DATABASE_NAME=marketflow
DATABASE_USER=marketflow
DATABASE_SSLMODE=disable
```

Password is managed only through Kubernetes Secret.

## Deploy

All Kubernetes operations must run through workstation `192.168.55.148`.

This repo is intended to be synced by Argo CD. It does not need a build runner unless custom DB images are introduced later.

## Components

- `deploy/k8s/namespace.yaml`
- `deploy/k8s/postgres-timescaledb.yaml`
- `deploy/k8s/postgres-backup-cronjob.yaml`
- `deploy/db/init/001_extensions.sql`
- `deploy/db/init/002_schema.sql`
- `deploy/db/init/003_timescale_policy.sql`
- `deploy/db/init/004_continuous_aggregate.sql`
- `deploy/docker-compose.yml`

## Verify

```bash
kubectl -n marketflow get pod,pvc,svc
kubectl -n marketflow exec -it statefulset/marketflow-db -- psql -U marketflow -d marketflow
```

SQL checks:

```sql
SELECT extname FROM pg_extension;
SELECT * FROM timescaledb_information.hypertables;
SELECT * FROM timescaledb_information.compression_settings;
```

## Backup

`postgres-backup-cronjob.yaml` runs `pg_dump` every day at `03:00`.

The MVP stores backup files under `/backup` in a PVC. NAS/NFS backup export can be added later.

## Storage

The cluster currently only has the `nfs-client` StorageClass. PostgreSQL initialization performs ownership changes on `PGDATA`, and the NFS provisioner rejects that operation. For the MVP, the database StatefulSet is pinned to `worker-03` and stores data on:

```text
/var/lib/marketflow/timescaledb
```

Move this to a proper local PV, Longhorn, Rook/Ceph, CloudNativePG storage, or another PostgreSQL-compatible block storage before HA production use.

## Notes

- TimescaleDB image tag is pinned to the PostgreSQL major tag: `latest-pg16`.
- The Kubernetes manifest references the internal registry mirror:
  `192.168.55.148:5000/mirror/docker.io/timescale/timescaledb:latest-pg16`.
- Do not hardcode real passwords in code or manifests.
