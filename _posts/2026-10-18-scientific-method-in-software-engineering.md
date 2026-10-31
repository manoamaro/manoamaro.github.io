---
title: Applying the scientific method to software engineering
description: How researching existing solutions, testing assumptions, and arguing from evidence can improve the way we implement solutions at work.
category_label: Engineering
date: 2026-10-18 00:00:00 Z
tags:
- software engineering
- scientific method
- research
- decision making
layout: post
---

When we discuss a technical problem at work, it is easy to jump straight to a solution. Someone suggests a library, another person proposes a new service, and soon we are comparing implementations before agreeing on what needs to improve.

I think the scientific method gives us a useful way to organise these decisions. Observe the problem, research what is already known, propose an explanation, and test it. Then use the results to decide what to do next.

Software engineering also involves deadlines, budgets, and product decisions. We won't resolve every question with an experiment. But we can make our assumptions visible, look for evidence, and explain how that evidence supports our choices.

### Start with an observation

For example, imagine a team investigating a slow endpoint. This is a hypothetical example, but the situation should be familiar.

“The endpoint is slow” is a starting observation. “We need a cache” is already a proposed solution. Between those two statements, there are several things we still need to understand.

Which requests are slow? Under what load? Where does the time go? Is the problem recent? What response time do users actually need?

A useful problem statement might be:

> During peak traffic, the product endpoint exceeds our agreed response-time target. We need to identify the bottleneck and reduce response time while preserving the required freshness of product information.

Now we have something to investigate. We also have a constraint: returning an old price quickly might not count as an improvement.

Before changing anything, I would record a baseline. That means measuring the current behaviour under known conditions: request volume, latency distribution, errors, resource use, and relevant traces. An average alone can hide a small group of requests taking much longer, so the measurements should reflect the experience we care about.

### Research before implementing

Once the problem is clearer, the next question is what we already know about solving it.

I would start inside the system. Existing code, traces, query plans, previous incidents, and earlier design decisions can explain why the current implementation behaves as it does. A decision that looks strange today may have addressed a constraint that still exists.

Then I would look at external sources: official documentation, relevant standards, research papers, and detailed accounts of comparable implementations. The goal is to understand the available approaches and the conditions under which they work.

For our endpoint, that could mean researching database indexing, query batching, connection pooling, and caching. Discovering that the database already provides a suitable feature could save us from building and maintaining another service.

However, finding a solution in a respected source doesn't establish that it fits our workload. A benchmark with different data, hardware, or consistency requirements is evidence about that benchmark. We still need to investigate whether its conclusions apply here.

### Map the alternatives against the problem

Research becomes more useful when we turn it into a comparison. Otherwise, we can collect links for days without getting closer to a decision.

For the endpoint example, an initial map might look like this:

| Approach | When it might help | What I would verify |
| --- | --- | --- |
| Add or change an index | The query scans too much data | Query plan, read latency, write cost, and storage |
| Batch repeated queries | One request makes many similar database calls | Call count, total request time, and result correctness |
| Cache responses | Requests repeat and some staleness is acceptable | Hit rate, freshness, invalidation, and failure behaviour |
| Keep the current design | The observed behaviour already meets the requirement | Representative measurements and remaining capacity |

These are hypotheses to investigate, not conclusions about an actual system.

The best approach depends on our objective and constraints. A small query change might meet the target with less operational work than introducing a distributed cache. Another workload might justify the cache. We should be able to explain the difference using the requirements and evidence available to us.

I also want the comparison to include implementation effort, ongoing maintenance, and how easily we can reverse the change. Performance is only one part of the decision.

### Make the hypothesis testable

“Caching is faster” is too broad to guide an experiment. A more useful hypothesis is:

> Repeated reads account for enough of this endpoint's database time that a response cache can bring latency within our target, while keeping data freshness within the agreed limit.

This statement connects an expected cause to an observable result. It also gives us ways to find out that we are wrong. Perhaps requests rarely repeat. Perhaps the expensive part is an external call. Perhaps acceptable freshness leaves too little time for useful cache reuse.

Before running the test, we should agree on what success means. In this example, that includes a latency target, an acceptable error rate, a freshness limit, and resource costs. Choosing those criteria after seeing the results makes it too easy to favour the outcome we wanted.

The [NIST explanation of experimental design](https://itl.nist.gov/div898/handbook/pri/section1/pri11.htm) describes planning experiments around objectives and selected factors so that the results support valid conclusions. For an engineering investigation, that means deciding what question a test should answer before collecting numbers.

### Apply the smallest useful experiment

I would first build enough to test the hypothesis. A query-plan comparison or a focused prototype might answer the question before a full implementation is necessary.

The comparison needs conditions we can describe and reproduce. We should record the code version, configuration, dataset, workload, and measurement procedure. For a cache, both warm and cold behaviour matter. A test where every request hits the cache cannot tell us what happens after a restart or during a change in traffic.

We also need to account for other changes. Comparing yesterday's peak traffic with today's quiet period doesn't isolate the effect of our implementation. A controlled load test can help, although its conclusions are limited by how well the workload represents production. Repeated runs help reveal variation; they don't repair an unrepresentative test.

A small improvement within normal measurement variation is weak evidence. A promising result should include enough observations to assess that variation, rather than just the fastest run.

If the experiment doesn't support the hypothesis, that is useful information. We can reject the approach, revise the explanation, or improve the test. Continuing because we have already spent time on the prototype would make the decision harder to defend.

### Verify the complete behaviour

Once an approach looks suitable, implementation still needs to preserve the system's requirements.

For caching, that means testing invalidation, stale data, failures, concurrency, and recovery, as well as the fast path. A latency improvement doesn't compensate for returning incorrect results.

Production also introduces conditions that our test environment may miss. Where the system supports it, a limited rollout lets us evaluate a change before exposing everyone to it. Google's [chapter on canarying releases](https://sre.google/workbook/canarying-releases/) describes comparing a partial deployment with a control and choosing representative traffic, duration, and metrics.

A successful canary increases confidence within the conditions it observed. We should still monitor the wider rollout and have clear rollback criteria.

### Build an argument that others can inspect

At some point, we need to explain the decision to colleagues. I find a technical argument more useful when it connects four things:

1. **The claim:** what we recommend changing.
2. **The evidence:** the observations, experiments, and sources supporting it.
3. **The reasoning:** why that evidence supports this choice for our system.
4. **The limits:** what remains uncertain and what would make us reconsider.

For example, “the documentation says this feature reduces database calls” supports an explanation of how the feature works. Measurements from our workload are needed to support a claim about how much it improves our endpoint. Neither statement alone tells us whether the trade-offs are acceptable.

Facts, interpretations, and preferences should be distinguishable. A trace showing repeated queries is an observation. Saying those queries are the main bottleneck is an interpretation to check. Accepting some staleness in exchange for lower latency is a product decision.

Sources should be specific enough for someone else to inspect: the documentation version, benchmark setup, query plan, or experiment report. A link attached to a claim is useful only if it actually supports that claim. We should also include results that weaken our recommendation, rather than selecting only the favourable ones.

Disagreement becomes more productive when we can identify whether we disagree about the evidence, the explanation, or the trade-offs. A colleague may accept our measurements and still reasonably prefer a simpler implementation.

### Keep the reasoning after the decision

A short decision record can preserve the problem, alternatives considered, evidence, chosen approach, and remaining risks. It should also say what would trigger a review: a different workload, a new requirement, or an assumption that turns out to be false.

The amount of investigation should match the consequences. A small, reversible change may need a focused check and a short explanation. A costly migration or a change to critical data deserves more evidence. We also need a stopping point: enough confidence to make the decision, with an appropriate way to detect and respond if it is wrong.

For me, this is the practical value of scientific thinking at work. It gives us a way to move from an initial idea to a decision that colleagues can examine, test, and improve. We can still use experience and intuition to suggest solutions, while letting evidence determine how much confidence those solutions deserve.
