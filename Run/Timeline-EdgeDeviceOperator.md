# edge-device-operator

## Project Goal (freeze this)

**Build a minimal Kubernetes Operator that manages unreliable “devices” using a declarative API, a persistent state machine, and a reconcile loop, demonstrating failure recovery and safe concurrency.**

Non-goals (explicit):

* No real hardware
* No cloud provider specifics
* No production hardening
* No feature completeness
* No real Kubernetes, especially under Chinese internet

---

## Milestone 0 — Reset & Scope Lock (1–2 days)

**Exit criteria:** You have a runnable empty operator and a frozen MVP definition.

### Checklist

**Environment**

* [x] Install kubectl
* [x] Install Go (>=1.21)
* [x] Install kind (or k3d)
* [x] Install docker
* [x] Create local cluster (kind create cluster)
* [x] Verify kubectl get nodes works

**Operator scaffold**

* [x] Install kubebuilder
* [ ] kubebuilder init (Go, controller-runtime)
* [ ] kubebuilder create api (group=edge, version=v1, kind=DeviceDeployment)
* [ ] CRD installs successfully
* [ ] Controller starts and logs reconciliation events

**MVP freeze (write this down, do not change later)**

* [ ] Exactly **1 CRD**
* [ ] Exactly **1 controller**
* [ ] Exactly **1 simulator**
* [ ] Exactly **5 states**
* [ ] Exactly **1 failure scenario**
* [ ] README includes explicit “Out of Scope” section

---

## Milestone 1 — Declarative API & State Machine Design (2–3 days)

**Exit criteria:** CRD schema + state machine are finalized and documented.

### Checklist

**CRD spec (desired state)**

* [ ] spec.image (string)
* [ ] spec.retryPolicy.maxAttempts (int)
* [ ] spec.retryPolicy.backoffSeconds (int)
* [ ] spec.concurrencyHint (optional, informational)
* [ ] spec.deviceRef (logical identifier, not Pod name)

**CRD status (actual state)**

* [ ] status.phase (enum)
* [ ] status.attempts (int)
* [ ] status.lastTransitionTime (timestamp)
* [ ] status.lastError (string)
* [ ] status.conditions (Progressing / Failed / Succeeded)

**State machine (persisted, not in-memory)**

* [ ] Pending
* [ ] Transferring
* [ ] Rebooting
* [ ] Verifying
* [ ] Succeeded
* [ ] Failed (terminal only after policy exhausted)

**Rules (write explicitly in README)**

* [ ] All transitions are monotonic
* [ ] Reconcile is idempotent
* [ ] Controller restart must not lose progress
* [ ] Status is the single source of truth

This milestone explicitly encodes your **previous project philosophy**.

---

## Milestone 2 — Device Simulator (Minimal & Adversarial) (2–3 days)

**Exit criteria:** Simulator reliably produces failure conditions.

### Checklist

**Simulator constraints**

* [ ] Runs as a Pod
* [ ] Exposes HTTP API only
* [ ] No shared state outside the Pod

**Endpoints**

* [ ] POST /burn?image=xxx

  * [ ] Random delay
  * [ ] Random mid-transfer failure
* [ ] POST /reboot

  * [ ] Becomes unreachable for N seconds
* [ ] GET /health

  * [ ] Occasionally returns stale or incorrect state

**Failure guarantees**

* [ ] At least one deterministic failure path for demo
* [ ] No assumptions of reliability

Important:
The simulator exists to **stress the controller**, not to be realistic.

---

## Milestone 3 — Reconcile Loop + State Machine Execution (3–4 days)

**Exit criteria:** End-to-end happy path works and survives restarts.

### Checklist

**Reconcile structure**

* [ ] Read CR
* [ ] Switch on status.phase
* [ ] Perform one small action
* [ ] Update status
* [ ] Return reconcile.Result (requeue as needed)

**Idempotency checks**

* [ ] Transfer step detects “already at image”
* [ ] Reboot step tolerates repeated calls
* [ ] Verify step tolerates transient failure

**Crash safety**

* [ ] Kill controller Pod mid-transfer
* [ ] Restart controller
* [ ] Reconcile resumes from correct phase

This is the **core value** of your project. Do not rush this milestone.

---

## Milestone 4 — Concurrency & Failure Recovery (2–3 days)

**Exit criteria:** Multiple CRs run safely in parallel.

### Checklist

**Concurrency**

* [ ] MaxConcurrentReconciles > 1
* [ ] Multiple DeviceDeployment CRs applied
* [ ] No shared mutable state between reconciles

**Failure handling**

* [ ] Retry attempts incremented correctly
* [ ] Backoff respected
* [ ] Failed only after maxAttempts exceeded

**Demonstration**

* [ ] One CR fails then recovers
* [ ] One CR fails permanently
* [ ] Others continue unaffected

This milestone directly maps to:

* concurrency
* isolation
* failure containment

---

## Milestone 5 — Packaging & Hiring Readability (2–3 days)

**Exit criteria:** A German interviewer can understand it in 10 minutes.

### Checklist

**Packaging**

* [ ] Multi-stage Dockerfile
* [ ] kustomize or plain YAML
* [ ] Single “make demo” command

**Documentation**

* [ ] Architecture overview
* [ ] Reconcile loop explanation
* [ ] State machine table
* [ ] Failure model
* [ ] Trade-offs & omissions

**Explicit mapping section**

* [ ] “How this mirrors an industrial control plane”
* [ ] Declarative desired vs observed state
* [ ] Persisted state machine
* [ ] Crash recovery semantics

---

## Optional Milestone 6 — One Infra Signal (Optional, ≤2 days)

Pick **one**, then stop.

* [ ] Prometheus metrics
* [ ] Kubernetes Events per transition
* [ ] Leader election (HA controller)
* [ ] Finalizers for cleanup semantics

---

## Final Reality Check (important)

If this project:

* exceeds **~3 weeks of focused effort**
* starts growing new features
* becomes “interesting engineering”

You are **hurting your job prospects**, not helping them.

This is a **signal adapter**, not a masterpiece.

If you want next:

* I can give you the **exact CRD YAML**
* Or the **exact reconcile pseudo-code**
* Or a **day-by-day calendar schedule**

Say which one.
