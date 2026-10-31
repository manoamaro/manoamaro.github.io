---
title: Dynamic Programming - Solving the same problem only once
description: A practical introduction to dynamic programming, memoization, and bottom-up tables, with Go examples from my Advent of Code solutions.
category_label: Algorithms
date: 2026-03-15 00:00:00 Z
tags:
- algorithms
- dynamic programming
- go
- advent of code
layout: post
---

Some coding challenges look manageable until we start exploring all the possible answers. For each choice there are more choices, and soon the program is doing far more work than we expected. Sometimes, a large part of that work is solving the same smaller problem again and again.

**Dynamic programming** helps us avoid that repetition. In this post I'm going to explain what it is, when it helps, and how it appears in a few of my Advent of Code solutions in Go.

### What is dynamic programming?

The idea is to describe a problem using smaller problems, save their answers, and reuse those answers when we need them again. Instead of exploring the same branches repeatedly, we calculate each distinct subproblem once.

There are two useful ways to do this:

- **Top-down, with memoization:** start with the original problem, solve smaller problems recursively, and cache the results.
- **Bottom-up, with tabulation:** start with the simplest answers and fill a table in an order where each answer's dependencies are already available.

These are two ways to evaluate the same relationship between problems. MIT's [introduction to dynamic programming](https://ocw.mit.edu/courses/6-s095-programming-for-the-puzzled-january-iap-2018/8706beaa535711f0af45ce2e86f3c9c2_MIT6_S095IAP18_Puzzle_11.pdf) gives another explanation of overlapping subproblems and memoization.

Recursion by itself isn't dynamic programming. If every recursive call solves a different problem, adding a cache might only use more memory. The important part is finding repeated work with reusable answers.

### An example: building a design from patterns

In [Advent of Code 2024, Day 19](https://adventofcode.com/2024/day/19), we have a collection of towel patterns and want to know whether we can join them to form a design. Each pattern can be used repeatedly. My [solution](https://github.com/manoamaro/advent-of-code/blob/main/cmd/2024/19/main.go) also counts how many arrangements produce each design.

Let's use a smaller example with patterns `a` and `aa`. How many ways can we build `aaaa`?

```text
a + a + a + a
a + a + aa
a + aa + a
aa + a + a
aa + aa
```

There are five ways. We could find them by trying every possible first pattern, then doing the same for what remains.

If we start with `a`, the remaining design is `aaa`. If we start with `aa`, it is `aa`. But solving `aaa` also leads to `aa`, so we have reached the same smaller problem through two different choices.

That remaining design is our **state**: the information needed to describe a subproblem. With the available patterns fixed, the number of ways to build `aa` doesn't depend on how we arrived there.

Now we can define the rule, or **recurrence**:

```text
ways(remaining) = sum of ways(remaining after removing a matching prefix)
ways("") = 1
```

Why does the empty design have one way? Because consuming the entire design means we completed one valid arrangement. Returning zero there would erase every successful branch when we add the counts together.

### A top-down solution in Go

Here is a standalone adaptation of the approach in my Day 19 solution. I've replaced the repository's set and map helpers with a slice and a standard Go map to keep the example self-contained. It needs `import "strings"`.

{% highlight go %}
func countDesign(design string, patterns []string) uint64 {
	memo := make(map[int]uint64)

	var ways func(int) uint64
	ways = func(start int) uint64 {
		if start == len(design) {
			return 1
		}
		if result, ok := memo[start]; ok {
			return result
		}

		var total uint64
		for _, pattern := range patterns {
			if pattern != "" && strings.HasPrefix(design[start:], pattern) {
				total += ways(start + len(pattern))
			}
		}
		memo[start] = total
		return total
	}

	return ways(0)
}
{% endhighlight %}

For example, `countDesign("aaaa", []string{"a", "aa"})` returns `5`.

Here `start` is the byte position of the remaining suffix. Instead of storing that suffix as a string key, we store its position in the fixed design. The puzzle uses ASCII characters, so byte positions are sufficient.

Every accepted pattern moves `start` forward. Empty patterns are ignored because they wouldn't consume anything and would make the recursion call itself with the same state. The example assumes the patterns are unique; duplicate entries would count the same choice twice. My original parser puts them in a set.

The map lookup uses `result, ok` because zero is a valid cached answer. A suffix that cannot be built is worth remembering too.

For the yes-or-no question, we can use a similar function returning `bool`, combine branches with OR, and stop at the first success. That is what the separate `isPossible` function in my repository does. Counting needs to add every successful branch.

### How much work does it save?

With patterns `a` and `aa`, the uncached recursion follows a Fibonacci-like branching pattern. The number of calls grows exponentially with the design length, even though many calls ask about the same suffix.

Let **N** be the design's length in bytes, **P** the number of patterns, and **L** the longest pattern length. The memoized example has at most N + 1 states. Each state checks P patterns, and a prefix comparison can inspect up to L bytes.

That gives an upper bound of **O(N × P × L)** time, assuming expected constant-time map operations and fixed-width arithmetic. The memo and recursion stack use **O(N)** auxiliary space. We are counting arrangements without constructing all of them.

This is a useful way to analyse a dynamic programming solution: count the states, then estimate the work per state. A cache doesn't automatically make an algorithm linear.

The example uses `uint64`, which can still overflow if the number of arrangements is too large. For unrestricted counts we would need overflow checks or arbitrary-precision integers, and the arithmetic cost would also change.

### The same problem, bottom-up

We can also fill a table without recursion. Let `dp[start]` mean the number of ways to build the suffix beginning at `start`.

{% highlight go %}
func countDesignBottomUp(design string, patterns []string) uint64 {
	dp := make([]uint64, len(design)+1)
	dp[len(design)] = 1

	for start := len(design) - 1; start >= 0; start-- {
		for _, pattern := range patterns {
			if pattern != "" && strings.HasPrefix(design[start:], pattern) {
				dp[start] += dp[start+len(pattern)]
			}
		}
	}

	return dp[0]
}
{% endhighlight %}

The assumptions about unique patterns and integer size are the same as before.

We work backwards because every matching nonempty pattern leads to a larger position. Its answer must already be in the table before we use it.

For our example, the table ends up like this:

| Position | Remaining design | Ways |
| --- | --- | --- |
| 4 | empty | 1 |
| 3 | `a` | 1 |
| 2 | `aa` | 2 |
| 1 | `aaa` | 3 |
| 0 | `aaaa` | 5 |

Both versions use the same recurrence and have the same time bound. The bottom-up version avoids the growing call stack and uses a slice for direct indexing. The top-down version can skip states which are never reached from the starting problem.

### Choosing the right state: Hot Springs

A cache is only correct if its key contains everything that can change the answer.

My [2023 Day 12 solution](https://github.com/manoamaro/advent-of-code/blob/main/cmd/2023/12/main.go) is a useful example. In [Hot Springs](https://adventofcode.com/2023/day/12), a row contains working springs (`.`), damaged springs (`#`), and unknown positions (`?`). A list of group sizes describes the required consecutive runs of damaged springs. We need to count the arrangements which satisfy both pieces of information.

In that solution, the recursive function receives the remaining row and the remaining groups. This is its actual cache lookup:

{% highlight go %}
key := fmt.Sprintf("%s-%v", input, groups)
if val, ok := memo[key]; ok {
	return val
}
{% endhighlight %}

Caching only the remaining row would be wrong. For example, a row containing one `?` has one valid arrangement when the remaining group is `[1]`, but none when it is `[2]`.

The function either treats the next position as working, when allowed, or places the next complete damaged group. Placing a group also checks its length and separator before advancing past it. Because each call starts outside a partially placed group, the remaining row and groups are sufficient to describe the state.

That last detail matters. A version which consumes one spring at a time might also need the length of the currently open damaged run in its cache key. The right state depends on how we define the subproblem.

My implementation formats strings for the key. Another representation would use a struct containing the row position and group index, with a fresh cache for each fixed row and group list. That would avoid formatting the remaining values on each lookup.

### When should I use it?

When a problem involves counting possibilities, finding a minimum cost, or deciding whether some arrangement is possible, I look for a few things:

1. Can I describe a smaller version of the problem with a compact state?
2. Can I calculate its answer from smaller states, with clear base cases?
3. Do different choices reach the same states?
4. Are there few enough distinct states to store and process?

For optimisation problems, we also need to know that the best answer can be built from the appropriate best subproblem answers. This is usually called **optimal substructure**. A locally attractive choice isn't enough to justify discarding the other choices.

Dynamic programming isn't always the right tool. Merge sort splits into separate subproblems without the same repeated-state benefit. Breadth-first search is a direct fit for shortest paths in an unweighted graph. And if every state includes an arbitrary subset of N items, the cache may still contain exponentially many states.

There is one more practical detail in my Day 19 solution: the cache is cleared at the start of each part and shared across designs using the same pattern set. A cached suffix answer can be reused there because the patterns stay fixed. If the patterns changed, the suffix alone would no longer be a sufficient key. The standalone functions above avoid that issue by creating a fresh table for every call.

What helps me recognise dynamic programming is asking what a recursive call actually needs to know. In Day 19, that is the remaining design. In Day 12, it is the remaining row and groups. Once that state is clear, I can write the recurrence, check the base cases, and decide how to save the answers.
