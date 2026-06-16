# Findings

Record every issue you spot here — **even if you don't fix it**. This is scored.

For each, a one-liner is enough: where it is, why it's a problem, and (if you didn't fix it)
what you would do. Severity tags (blocker / should-fix / nice-to-have) are welcome.

---

## Task 1 — Kubernetes

| # | File / area | Issue | Severity | Fixed? | Notes / how to fix |
|---|-------------|-------|----------|--------|--------------------|
| 1 | `kubernetes/app/Dockerfile:7` | Base image tag `node:18-slimm` is a typo — does not exist on Docker Hub | **blocker** | Yes | Changed to `node:18-slim`. Docker fails immediately with "manifest unknown" until fixed. |
| 2 | `kubernetes/app/Dockerfile:10` | `curl vim build-essential` installed in production image — adds ~200MB and a C compiler to the attack surface | **should-fix** | Yes | Removed entirely. No debug or build tools belong in a production container image. |
| 3 | `kubernetes/app/Dockerfile:20` | `ENV MONGO_PASSWORD=sup3rs3cr3t-changeme` — password baked into image layer, readable via `docker inspect` or `docker history` | **should-fix** | Yes | Removed. Credentials must be injected at runtime via Kubernetes Secret and `secretKeyRef`. |
| 4 | `kubernetes/app/Dockerfile:15` | `COPY . .` copies entire build context before `npm install` — any file change invalidates the npm install cache | **nice-to-have** | Yes | Split into `COPY package*.json ./` then `RUN npm install --omit=dev` then `COPY server.js ./` for proper layer caching. |
| 5 | `kubernetes/helm-charts/api-service/templates/deployment.yaml:21` | `ports` block indented at wrong level — sits outside the container object, making `env`, `livenessProbe`, `readinessProbe`, and `resources` orphaned | **blocker** | Yes | Added 2 spaces so `ports` and all following blocks are correctly nested inside the container item. |
| 6 | `kubernetes/helm-charts/api-service/templates/deployment.yaml:30–35` | Liveness probe hits `/healthz` which pings MongoDB — a slow DB causes healthy pods to be killed and restarted unnecessarily | **should-fix** | Yes | Changed liveness probe to `GET /` (lightweight, always returns 200). Readiness probe stays on `/healthz`. |
| 7 | `kubernetes/gitops/sandbox/api-service/kustomization.yaml:7` | `chartHome: ../../../helm-chart` — directory is named `helm-charts` (plural), path resolves to nothing | **blocker** | Yes | Changed to `../../../helm-charts`. Kustomize cannot find the chart until this is fixed. |
| 8 | `kubernetes/gitops/sandbox/api-service/kustomization.yaml:20` | `images` transformer uses `name: api` — does not match the Helm chart image name `api-service`, transformer silently skips it | **should-fix** | Yes | Changed to `name: api-service` to match the repository name in `values.yaml`. |
| 9 | `kubernetes/gitops/sandbox/api-service/kustomization.yaml:27` | Patch target `name: api-svc` does not match Helm release name `api-service` — resource patch silently does nothing | **blocker** | Yes | Changed to `name: api-service`. Without this fix pods deploy with no resource requests or limits. |
| 10 | `kubernetes/helm-charts/api-service/values.yaml:5–6` | `tag: latest` with `pullPolicy: Always` — non-deterministic version and fails in kind because there is no registry to pull from | **should-fix** | Yes | Changed to `tag: sandbox` and `pullPolicy: IfNotPresent`. In production use a git SHA or semver tag. |
| 11 | `kubernetes/helm-charts/api-service/values.yaml:17` | MongoDB URI missing `.data.` namespace — `mongodb-0.mongodb.svc.cluster.local` should be `mongodb-0.mongodb.data.svc.cluster.local` | **should-fix** | Yes | Corrected full DNS. Removed auth credentials since sandbox MongoDB has auth disabled. Added `?replicaSet=rs0` required by the Node.js MongoDB driver. |
| 12 | `kubernetes/helm-charts/api-service/values.yaml:17–18` | Plaintext credentials in `values.yaml` committed to source control | **should-fix** | Yes | Removed URI credentials and cleared password field. Proper fix is referencing a Kubernetes Secret via `secretKeyRef` in the Deployment env vars. |
| 13 | `kubernetes/helm-charts/api-service/values.yaml:20` | `resources: {}` — no CPU or memory requests or limits defined | **should-fix** | Yes | Set `requests: {cpu: 50m, memory: 64Mi}` and `limits: {cpu: 200m, memory: 128Mi}`. |
| 14 | `kubernetes/helm-charts/api-service/values.yaml:1,23–24` | `replicaCount: 1` with `pdb.enabled: false` — any node drain takes the service down with no replacement | **should-fix** | Yes | Changed to `replicaCount: 2` and `pdb.enabled: true`. PDB with `minAvailable: 1` requires at least 2 replicas to be effective. |
| 15 | `kubernetes/helm-charts/api-service/templates/secret.yaml` | Secret resource is created but never referenced by the Deployment — credentials still pass through plain `value:` env vars | **nice-to-have** | No | Wire up via `secretKeyRef` in Deployment env vars, or remove to avoid dead configuration. |

---

## Task 2 — Terraform

| # | File / area | Issue | Severity | Fixed? | Notes / how to fix |
|---|-------------|-------|----------|--------|--------------------|
| 1 | `terraform/modules/mongodb-instance/main.tf:10` | `var.disk_siz_gb` — typo, variable is declared as `disk_size_gb` | **blocker** | Yes | Changed to `var.disk_size_gb`. `terraform validate` fails with "argument not expected" until fixed. |
| 2 | `terraform/modules/mongodb-instance/main.tf:5` vs `variables.tf:10` | `zone` variable declared and passed by caller but resource hardcoded `"us-central1-a"` — variable was completely ignored | **should-fix** | Yes | Changed to `zone = var.zone`. Module must use its own variables to be reusable across environments. |
| 3 | `terraform/modules/mongodb-instance/main.tf:14–16` | `access_config {}` — empty block assigns an ephemeral public IP to every MongoDB instance | **should-fix** | Yes | Commented out `access_config {}`. Database servers must not be publicly reachable. Use Cloud NAT for outbound and IAP or bastion for admin access. |
| 4 | `terraform/modules/mongodb-instance/variables.tf:6–8` | `replica_count` had no `type` declaration — Terraform accepts any value without validation | **should-fix** | Yes | Added `type = number` and `description`. |
| 5 | `terraform/modules/mongodb-instance/variables.tf:10–11` | `zone` variable had no `type`, no `description` — undocumented and unvalidated | **should-fix** | Yes | Added `type = string`, `description`, and `default = "us-central1-a"`. |
| 6 | `terraform/sandbox/mongodb-api-service/main.tf:4–8` | Google provider had no version constraint — `terraform init` could pull a breaking major version silently | **should-fix** | Yes | Added `version = "~> 7.0"`. Allows minor and patch updates but blocks breaking major version changes. |
| 7 | `terraform/modules/mongodb-instance/main.tf:5` | All replica set instances land in the same zone — a single zone outage takes down the entire replica set | **should-fix** | No | Distribute across `us-central1-a/b/c`. Change `zone` to `list(string)` and use `var.zone[count.index % length(var.zone)]`. |
| 8 | `terraform/sandbox/mongodb-api-service/state.tf` | S3 (AWS) backend configured for a GCP project — cross-cloud state dependency with no benefit | **should-fix** | No | Replace with GCS backend: `backend "gcs" { bucket = "..." prefix = "mongodb-api-service" }`. |
| 9 | `terraform/modules/mongodb-instance/main.tf` | No network tags defined — cannot write targeted GCP firewall rules to restrict MongoDB port 27017 | **should-fix** | No | Add `tags = ["mongodb-replica"]` to the instance and create a matching firewall rule for port 27017. |

---

## Task 3 — Chef

| # | File / area | Issue | Severity | Fixed? | Notes / how to fix |
|---|-------------|-------|----------|--------|--------------------|
| 1 | `chef/cookbooks/mongodb/recipes/default.rb:23` | `mongo --eval "rs.initiate()"` — `mongo` shell was removed in MongoDB 6.0, replaced by `mongosh` | **blocker** | Yes | Changed to `mongosh --quiet --eval "rs.initiate()"`. Any system running MongoDB 6.0 or later gets "command not found" until fixed. |
| 2 | `chef/cookbooks/mongodb/recipes/default.rb` | Wrong execution order — replica set init ran before `mongod` was started; `systemctl enable` registers for boot but does not start the service | **blocker** | Yes | Reordered: install → create data dir → write config → start service → init replica set. |
| 3 | `chef/cookbooks/mongodb/recipes/default.rb:21–25` | `rs.initiate()` not idempotent — throws `AlreadyInitialized` on every Chef run after the first, failing the converge | **should-fix** | Yes | Added `not_if` guard to check replica set status before running init. |
| 4 | `chef/cookbooks/mongodb/recipes/default.rb:27–32` | Template resource had no `notifies` — changing `mongod.conf` writes the file but the running process never picks up the new config | **should-fix** | Yes | Added `notifies :restart, 'service[mongod]', :delayed`. |
| 5 | `chef/cookbooks/mongodb/recipes/default.rb:17–19` | `execute 'enable-mongod'` used raw `systemctl enable` shell command — not idempotent, not cross-platform, bypasses Chef's service resource | **should-fix** | Yes | Removed the `execute` block. Replaced with `action [:enable, :start]` on the service resource. |
| 6 | `chef/cookbooks/mongodb/recipes/default.rb:7–9` | `package 'mongodb-org'` installed without version pin — ignores `node['mongodb']['version']` attribute, installs whatever is latest | **should-fix** | Yes | Added `version node['mongodb']['version']` to the package resource. |
| 7 | `chef/cookbooks/mongodb/attributes/default.rb:5` | `version = '4.2.0'` — MongoDB 4.2 reached end-of-life October 2023, no security patches since that date | **should-fix** | Yes | Changed to `'8.0'`. |
| 8 | `chef/cookbooks/mongodb/attributes/default.rb:8` | `bind_ip = '0.0.0.0'` — binds MongoDB to all network interfaces including any public-facing ones | **should-fix** | Yes | Changed to `'127.0.0.1'`. Override per environment to the server's private IP for replica set communication. |
| 9 | `chef/cookbooks/mongodb/attributes/default.rb:12` | `admin_password = 'admin123'` — weak default password hardcoded in source control | **should-fix** | No | Change to a safe placeholder and override using Chef Vault or an encrypted data bag. Never store real credentials in attributes. |
| 10 | `chef/cookbooks/mongodb/templates/mongod.conf.erb:6` | `bindIp: 0.0.0.0` hardcoded in template — ignores `node['mongodb']['bind_ip']` attribute entirely | **should-fix** | Yes | Changed to `bindIp: <%= node['mongodb']['bind_ip'] %>`. The attribute had zero effect on the rendered config until this was fixed. |
| 11 | `chef/cookbooks/mongodb/templates/mongod.conf.erb:8–9` | `authorization: disabled` — any client can connect to MongoDB with no credentials required | **should-fix** | Yes | Changed to `authorization: enabled`. |
| 12 | `chef/cookbooks/mongodb/templates/mongod.conf.erb:14–17` | `setParameter adminUser/adminPassword` — not valid `setParameter` keys, MongoDB silently ignores them; no user is actually created | **should-fix** | Yes | Removed entire `setParameter` block. User creation must be done via `mongosh` script using MongoDB's localhost exception after service starts. |
| 13 | `chef/cookbooks/mongodb/recipes/default.rb` | No package repository resource — `mongodb-org` is not in default OS repos, install fails with "package not found" on a fresh host | **should-fix** | No | Add `apt_repository` or `yum_repository` resource before the package install to configure MongoDB's official repo. |

---

## Anything I'd do with more time

