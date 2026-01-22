
**Core mental model (non-negotiable)**

1. What *problem* does a Kubernetes controller solve that a cron job or script does not?
2. What does it mean for reconciliation to be **level-based** rather than **event-based**?
3. Why must a `Reconcile()` function be **idempotent（幂等）**?
4. What is the invariant that reconciliation tries to maintain?
5. What happens if the controller process crashes halfway through reconciliation?


1. A controller continuously reconciles desired state and actual state, tolerating crashes, retries, duplicates, and reordering, which imperative scripts cannot safely handle.
2. Level-based means reconciliation is driven by the current state comparison, not by individual events or commands.
3. Because the same reconciliation may run multiple times with no guarantees about ordering, duplication, or partial failure.
4. The invariant is that the controller never violates safety rules while monotonically driving actual state toward desired state.
5. The controller restarts, reads persisted state (CR spec + status), recomputes the next action, and safely continues because reconciliation is idempotent and state-driven.

---

**CRD as an API (this is where meaning starts)**

1. What is the CRD *actually representing* in my system: a task, a device, or an intent?
2. Why is **desired state** stored in `spec` instead of directly executing actions?
3. Why is **observed state** written to `status` instead of mutating `spec`?
4. What does Kubernetes gain by persisting `status` separately?
5.  Why should users never manually edit `status`?

---

**Reconcile loop mechanics (operator reality)**

11. What *exactly* triggers a reconciliation loop?
12. Why might reconciliation be called even if nothing “changed”?
13. Why should reconciliation be written as “**derive next state**” instead of “**do next step**”?
14. What happens if reconciliation runs twice concurrently for the same object?
15. What makes reconciliation safe to retry after failure?

---

**API naming (know the boundary, not the theory)**

16. What is an API **group** conceptually separating?
17. What does a **kind** represent in terms of domain modeling?
18. What would break if I renamed the group or kind after users already applied CRs?
19. Why is `v1` a promise rather than a technical detail?

---

**Status, conditions, and observability**

20. Why is a single `status.state` often insufficient in real systems?
21. What problem do **conditions** solve that a plain enum does not?
22. Why does Kubernetes encourage `observedGeneration`?
23. How does `status` act as a crash-recovery journal?

---

**Failure modeling (this is where your project differentiates)**

24. What does “failure” mean in a declarative system?
25. Why is “retry” not a special case but the default behavior?
26. Where should irrecoverable failure be recorded: code, logs, or API state?
27. How does the system behave if the failure disappears on its own?

---

**What kubebuilder is *actually* doing for you (demystification)**

28. What boilerplate does kubebuilder generate that you should *not* hand-write?
29. What parts of the scaffold will almost never change?
30. Which generated files are safe to ignore entirely during reasoning?
31. Why is kubebuilder intentionally verbose?

---

**Boundaries you are allowed to ignore (for now)**

32. Why do webhooks exist, and why don’t I need them now?
33. Why do leader election and HA matter later, not in MVP?
34. Why is metrics exposure orthogonal to correctness?
35. Why does adding more CRDs early usually weaken a demo?

---

**Reality check (the question that matters most)**

36. If Kubernetes disappeared tomorrow, which *ideas* from this project would still be valid?

If you can answer **1–15**, you are already interview-ready.
If you can answer **1–27**, you are operating at senior-infra level.
Everything else is optional.

If you want, next we can:

* Map each of these questions to **exact lines in your current code**, or
* Reduce this to a **one-page “operator mental model” note** you can reread when the “this is pointless” feeling comes back.

Tell me which direction you want.
