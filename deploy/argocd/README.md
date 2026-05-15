# Argo CD delivery

These manifests define the desired GitOps shape for staging and prod.

- `application-staging.yaml` syncs the staging Helm values.
- `application-prod.yaml` syncs the prod Helm values.
- Argo CD Image Updater is enabled only on staging.
- Prod receives the exact staging image digest through the manual GitHub
  promotion workflow.

Replace placeholder repo URLs, Argo CD project names, destination servers, and
hostnames when the live cluster setup is known.
