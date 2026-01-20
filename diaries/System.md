
# Constrained Cluster Management Control Plane
## System Background

The system was designed to manage and deploy a fleet of industrial CPU boards used in a production environment.

All devices are connected to the same physical switching infrastructure and operate under strict hardware and network constraints.
They are **not general-purpose servers** and run fixed firmware with extremely limited management capabilities.

Specifically:

* No SSH or remote shell access
* No application-level API
* No ability to install agents
* No direct way to query internal state
* UDP is the **only reliable signal** indicating that a device is alive.

All deployment and recovery operations must therefore be executed **externally**, without any manual intervention.
Physical access to devices is either unavailable or prohibitively expensive.

---

## Constraints

### Network and Addressing Constraints

All devices are shipped with the **same static IP address**, which cannot be modified.

Key constraints:

* The IP address is hard-coded in the firmware
* DHCP is not supported
* The IP address is required by the application logic
* Multiple devices with identical IPs must operate simultaneously

As a result, IP conflicts are **not an edge case**, but a guaranteed condition.

To enable parallel operation, the system relies on **VLAN-based network isolation**:

* Each deployment group is assigned a dedicated VLAN
* VLAN sub-interfaces are created dynamically by the controller
* Devices belonging to different tasks or users are isolated at Layer 2
* Multiple devices may coexist within the same VLAN despite sharing IP addresses

All VLAN configuration is created and managed programmatically by the system.

---
### Power Control Constraints

Devices do not provide any software-controlled reboot or shutdown interface.

Power cycling is implemented via:

* External relay (Moxa ioLogik 2210)
* Controlled through SNMP
* Physical power lines are routed through relay-controlled DI ports

The system must assume that:

* Power control may fail
* SNMP communication may be temporarily unavailable
* Devices may enter undefined states after reboot

No direct confirmation of successful power-on is available.

---

## System Goal

The primary goal of the system is:

**To reliably deploy and recover devices in a fully automated manner under unreliable network and hardware conditions.**

Key objectives:

* No manual intervention
* Reliability prioritized over performance
* Recovery from partial or failed deployments
* Support for batch operations
* Deterministic behavior under uncertainty

The system is not optimized for throughput, but for **operational safety and recoverability**.



---

### Core Challenge

The core difficulty of the system lies in the following:

Managing a multi-step deployment process when device state cannot be directly observed and must be inferred from indirect signals.

Specifically:

* Device identity is implicit rather than discoverable
* Device state must be inferred from historical actions
* Deployment is non-atomic
* Failures are frequent and unavoidable
* The system must remain correct even when assumptions break

All devices share the same static IP address, expose no management interface, and communicate only through unreliable channels.
As a result, the system cannot directly determine device state and must infer progress indirectly.

The challenge is to design a deployment mechanism that is:

* Idempotent under partial failure
* Recoverable after controller restarts
* Safe to retry without manual intervention
* Robust against network and device instability


## Architecture Overview

### High-Level Architecture

The system follows a **controller-based architecture** with a centralized control plane and externally managed devices.

At a high level, it consists of:

* A **Control Plane** responsible for orchestration and decision-making
* A **State Store (etcd)** used for persistence and coordination
* A **Network Isolation Layer** based on VLANs
* A set of **Unmanaged Devices** with extremely limited interfaces
* External **Power Control Hardware** for forced recovery

The system does not rely on agents or remote execution on the devices.
All control is performed indirectly through network and power operations.

### Component Overview

#### 1. Control Plane

The control plane is the core of the system and is responsible for:

* Task scheduling and orchestration
* State machine execution
* VLAN lifecycle management
* Device deployment and recovery
* Failure detection and retry logic

It runs as a standalone service and interacts with all other components.

Key properties:

* Stateless in memory, state persisted in etcd
* Designed to tolerate crashes and restarts
* All operations are idempotent
* No dependency on device-side software

---

#### 2. State Store (etcd)

etcd is used as the **single source of truth** for system state.

It stores:

* Desired state of each device
* Current observed state
* Deployment task progress
* Lease information for leader election

The system uses etcd for:

* Persisting long-running workflows
* Coordinating active/standby controllers
* Recovering in-progress operations after failure

State is written in a way that allows a new controller instance to reconstruct progress and resume execution safely.

---

#### 3. Controller High Availability

The control plane runs in an **active–standby configuration**.

* Leader election is implemented using etcd leases
* Only the active leader is allowed to issue device operations
* Standby nodes continuously monitor lease state
* Failover occurs automatically if the leader becomes unresponsive

Failover characteristics:

* Expected recovery time: within ~10 seconds
* No manual intervention required
* In-progress tasks are resumed based on persisted state
* Duplicate execution is tolerated due to idempotent design

To prevent split-brain scenarios:

* Controllers continuously verify lease ownership
* A controller terminates itself if lease ownership is lost
* Watchdog restarts the process as a standby node

---

#### 4. Deployment Workflow

The deployment process is modeled as a **state machine**.

Typical stages include:

1. Network isolation (VLAN assignment)
2. File transfer via FTP
3. Power cycling via relay
4. Device boot
5. Health verification via UDP
6. Finalization or rollback

Each stage:

* Is independently retryable
* Has explicit success and failure conditions
* Can be resumed after interruption
* Produces deterministic side effects

The controller continuously reconciles the **desired state** with the **observed state** and advances the workflow accordingly.

---

#### 5. Network Isolation Layer

Because all devices share the same static IP, the system relies on VLAN-based isolation:

* VLANs are dynamically created by the controller
* Each task or user group is assigned a VLAN
* VLAN sub-interfaces are created on the controller host
* Traffic is isolated at Layer 2

This allows:

* Parallel deployment of identical devices
* Elimination of IP conflicts
* Deterministic routing of control traffic

The network layer is fully managed by the control plane and does not require manual configuration.

---

#### 6. Device Interaction Model

Devices are treated as **black boxes**.

The system interacts with them through:

* FTP for file transfer
* SNMP for power control
* UDP for liveness detection

No assumptions are made about:

* Device internal state
* Execution correctness
* Timing guarantees

All operations are designed under the assumption that:

* Commands may fail silently
* Devices may reboot unexpectedly
* Observed state may lag behind reality

---

#### 7. Failure Handling and Recovery

Failure is treated as a first-class scenario.

The system is designed to handle:

* Partial deployments
* Network interruptions
* Power failures
* Controller crashes
* Duplicate execution

Recovery strategy:

* Persist all state transitions
* Resume from last known stage
* Re-run operations safely
* Never rely on in-memory state

This ensures that the system can always make forward progress without human intervention.

---

## Summary

The architecture prioritizes:

* Correctness over performance
* Recoverability over speed
* Explicit state over implicit behavior
* Deterministic control over best-effort execution

It is designed for environments where:

* Devices are unreliable
* Observability is limited
* Failures are normal
* Automation must be trusted



## Design Decisions & Trade-offs

### 1. Declarative State Machine vs Imperative Workflow

#### Decision

The system is built around a **state-driven reconciliation model**, rather than an imperative, step-by-step execution flow.

#### Rationale

Due to the lack of reliable device feedback and the high probability of partial failure, an imperative model would be fragile:

* Execution may stop midway
* The controller may crash
* Device state cannot be queried directly
* Retrying blindly may cause inconsistent behavior

By modeling deployment as a **state machine**, the system can:

* Resume execution after failure
* Retry safely without duplicating side effects
* Infer progress from persisted state
* Recover from controller restarts

#### Trade-off

* Increased complexity in state modeling
* More logic required to handle transitions
* Harder to debug than linear scripts

However, this approach is necessary to achieve correctness under unreliable conditions.

---

### 2. VLAN-Based Isolation vs Device Reconfiguration

#### Decision

VLAN-based isolation was used instead of modifying device IP configuration or introducing NAT.

#### Rationale

* Device IP addresses are fixed and cannot be changed
* DHCP is not supported
* Device software depends on a fixed IP
* Multiple devices with identical IPs must operate simultaneously

Using VLANs allows:

* Parallel deployment without IP conflict
* No modification to device firmware
* Deterministic network isolation
* Full control from the controller side

#### Trade-off

* Requires switch and NIC configuration
* Adds operational complexity
* Increases coupling to network infrastructure

This trade-off was accepted because it moves complexity from the device side (uncontrollable) to the controller side (fully controlled).

---

### 3. No Agent-Based Architecture

#### Decision

No agent or runtime is deployed on the devices.

#### Rationale

* Devices do not support agent installation
* No remote execution capability
* Introducing an agent would violate system constraints
* Agent failures would be hard to diagnose or recover

Instead, the system relies exclusively on:

* FTP for delivery
* SNMP for control
* UDP for liveness

#### Trade-off

* Limited observability
* No fine-grained telemetry
* Higher reliance on inference

This was a conscious decision to favor **robustness under constraint** over feature richness.

---

### 4. Idempotency Over Transactionality

#### Decision

The system favors **idempotent operations** over transactional guarantees.

#### Rationale

* FTP does not support atomic operations
* Power cycling is inherently non-transactional
* Network failures are common
* Device state cannot be rolled back reliably

Therefore:

* All operations are designed to be safely repeatable
* State transitions are persistent
* Duplicate execution is allowed and expected

#### Trade-off

* More complex state management
* Requires careful design of side effects
* Cannot rely on “exactly-once” semantics

This approach ensures the system can always make forward progress.

---

### 5. Lease-Based HA Instead of External Orchestration

#### Decision

High availability is implemented using **etcd leases** rather than external systems such as Kubernetes leader election or distributed locks.

#### Rationale

* System must operate independently of orchestration platforms
* Simpler failure model
* Full control over failover semantics
* Easier to reason about in constrained environments

The lease model allows:

* Clear ownership of control
* Fast failover
* Explicit fencing behavior
* Deterministic recovery

#### Trade-off

* Requires careful time synchronization
* Lease logic must be implemented and maintained manually
* Less feature-rich than managed HA solutions

---

### 6. Reliability Over Performance

#### Decision

The system prioritizes **correctness and recoverability** over throughput or latency.

#### Rationale

* Deployment speed is not business-critical
* A failed deployment is significantly more costly than a slow one
* Human intervention is expensive or impossible

As a result:

* Operations are conservative
* Timeouts are intentionally long
* Verification is prioritized over speed

#### Trade-off

* Slower deployment times
* Lower throughput
* Higher perceived latency

This is acceptable given the operational context.



---

### Summary of Design Philosophy

The system is built around the following principles:

* **Assume failure is normal**
* **Prefer recoverability over performance**
* **Make all operations idempotent**
* **Infer state rather than assume it**
* **Move complexity to the controllable side**

These decisions allow the system to operate reliably in an environment where traditional assumptions about observability and control do not hold.

---

## Design Ownership

I was the technical owner of the system and responsible for its overall architecture and implementation.

My responsibilities included:

* Designing the deployment workflow and state machine
* Designing the VLAN-based isolation model
* Implementing reconciliation logic for unreliable devices
* Defining failure-handling and recovery strategies

Some infrastructure components were introduced at the organizational level, but all system-level design decisions and trade-offs were made by me.


状态机 + 重试 + 恢复
