# Motivation and Expectations: edge-device-operator

## Motivation

This project exists for a pragmatic reason: my previous production system cannot be disclosed or open-sourced. As a result, there is no public artifact that accurately reflects the engineering problems I have worked on or the design decisions I am capable of making.

Rather than attempting to generalize or sanitize that system post hoc, I decided to build a new project that *reconstructs the core constraints* of the original environment and exposes them in a form that is inspectable, reproducible, and technically honest.

However, such system does not translate into a universal language interlectual to HRs, and I decided to convert this into a **Kubernetes Operator**.

This is not a feature showcase. It is a constraint-driven system design exercise.

## Design Expectations and Phylosophy

The Edge Deploy Controller is designed around a small set of non-negotiable properties. Each property maps directly to a class of real-world failure modes commonly observed in edge or industrial environments.

### High Availability

The control plane must tolerate partial failures without manual intervention. Crashes, restarts, and leader loss are considered routine events rather than exceptional ones. State must survive process failure, and progress must resume deterministically after recovery.

High availability here is not framed as “five nines uptime,” but as *continuity of control under instability*.

### Failure-Oriented Engineering

Failures are assumed to be frequent, not rare. Every operation is designed to be:

* **Idempotent**: repeated execution produces the same outcome
* **Retry-safe**: retries do not amplify damage or corrupt state

Instead of optimizing for the happy path, the system is optimized for repeated partial execution, interruption, and resumption.

### Eventual Consistency via Declarative Design

The system follows a **declarative control model**. Desired state is recorded explicitly, while the controller continuously reconciles observed state toward that target.

Strong consistency is intentionally avoided. Instead, the system guarantees **eventual consistency** under unreliable communication, accepting temporary divergence as the cost of survivability.

### Explicit Modeling of Unreliable Devices

The project does not assume reliable networks or cooperative devices. Simulated devices may:

* Drop messages
* Respond late or out of order
* Reboot unexpectedly
* Report stale or contradictory state

This is a deliberate departure from typical CRUD-style backend systems, where infrastructure reliability is often taken for granted.

### Concurrency With Control

Concurrency is treated as a constrained resource. The system must avoid unbounded goroutine creation, uncontrolled fan-out, or implicit parallelism.

All concurrent behavior is explicitly bounded and coordinated. This is a conscious rejection of “just spawn a goroutine” as a default design pattern, in favor of **controlled concurrency**.

### System Observability

Observability is a first-class concern. The system exposes internal signals for both:

* **Devices**: liveness, state transitions, failure patterns
* **Control plane**: reconciliation progress, queue depth, retry behavior

Monitoring is not added for presentation purposes; it exists to validate whether the control assumptions hold under stress.

## Scope Discipline

The project is intentionally minimal. Each component exists only to demonstrate a specific capability or trade-off. Features that do not contribute to expressing these constraints are excluded, even if they would be considered “standard” in production systems.

The goal is clarity of design signal, not completeness.


