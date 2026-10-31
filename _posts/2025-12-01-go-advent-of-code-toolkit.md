---
title: Turning Advent of Code solutions into a small Go toolkit
description: How I organised my Advent of Code solutions in Go, with a shared runner, input processors, cached inputs, and reusable helpers.
category_label: Go
date: 2025-12-01 00:00:00 Z
tags:
- go
- advent of code
- tooling
- testing
layout: post
---

Solving an Advent of Code puzzle usually starts with reading some input, converting it into something useful, and calling the solution. After doing this for several days, I ended up with a collection of helpers around my Go solutions. The interesting part is deciding which pieces belong in that shared code and which ones should stay with the puzzle.

In this post I'm going to explain how my [Advent of Code repository](https://github.com/manoamaro/advent-of-code) is organised, and a few things I would still improve. It's a small toolkit for my own workflow, so some choices favour convenience over a more general design.

### One command for each day

Each solution is a separate Go command. The folders follow the year and day, with zero-padded day numbers:

```text
cmd/
  aoc/             # Runs a selected year and day
  generator/       # Creates the starting files for a day
  2024/
    01/
    02/
    05/
internal/
  aoc/             # Challenge runner and input handling
pkg/
  grid/
  queue/
  set/
  sliceutil/
```

For example, from the repository root, I can run a solution directly:

{% highlight sh %}
go run ./cmd/2024/05
{% endhighlight %}

This keeps each puzzle independent. Its parsing, types, and solution functions can all live in the same folder, without registering every day in one large application.

There is also a small command that selects the folder for me:

{% highlight sh %}
go run ./cmd/aoc -y 2024 -d 05 -p 1 --debug
{% endhighlight %}

The [command](https://github.com/manoamaro/advent-of-code/blob/main/cmd/aoc/main.go) formats the day with `fmt.Sprintf("%02d", day)`, builds a path such as `./cmd/2024/05`, and runs it with `os/exec`. It passes the supported flags to the day command and connects its standard input, output, and error streams to the terminal.

It isn't loading the solution dynamically into the same process. It's starting another `go run` command. For this workflow, that is enough, and I can still run any day directly when I want to debug it.

### Separating input from the solution

The shared runner connects three functions: an input processor and a solver for each part. These are the types used by the runner:

{% highlight go %}
type InputProcessor[T any] func(string) T

type Solver[T any, R comparable] func(T) R
{% endhighlight %}

Here, `T` is the parsed input type, and `R` is the result type. Both parts use the same types. The `comparable` constraint allows the runner's sample checks to compare an answer with the expected value using `==`.

For a simple puzzle, the input can remain a string. The [generator's template](https://github.com/manoamaro/advent-of-code/blob/main/cmd/generator/day.tmpl) starts with this structure, with the actual year and day filled in:

{% highlight go %}
var challenge = aoc.New(2024, 5, aoc.StringProcessor, part1, part2)

func main() {
    challenge.Run()
}

func part1(input string) int {
    return 0
}

func part2(input string) int {
    return 0
}
{% endhighlight %}

Those zeroes are just the starting point for the solution. For a more complex puzzle, I can replace `StringProcessor` with a parser that returns a custom struct, and change the solver arguments to that type. The runner also has processors for lines, integers, and grids, so I don't need to repeat those conversions every time.

One detail is that the runner processes the raw input separately for each part. So, if part one sorts a slice or changes a grid, part two gets a newly parsed value rather than that modified value. This costs another parsing pass, but makes the two parts easier to reason about. It assumes the parser itself creates fresh data instead of returning shared mutable state.

### Getting input without downloading it every time

The [input helper](https://github.com/manoamaro/advent-of-code/blob/main/internal/aoc/utils.go) first checks a local file such as `.cache/input_2024_5.txt`. If it finds non-empty cached content, it returns that content. Otherwise, it loads local configuration, reads `AOC_SESSION`, requests the input from Advent of Code, and saves the response in the cache.

The session value stays in local configuration. Neither `.env` nor `.cache/` belongs in the repository.

I can also provide a file explicitly:

{% highlight sh %}
go run ./cmd/aoc -y 2024 -d 05 --input path/to/input.txt
{% endhighlight %}

The outer command turns `--input` into the positional file argument understood by the day runner. This bypasses the input download and is useful when trying a small example or reproducing a parsing problem.

There are still rough edges in this helper. It should check the HTTP response status before saving the body, and handle cache-write errors explicitly. Otherwise, an error response could end up being treated as puzzle input. A cache is useful, but it also needs to be clear which responses are safe to keep.

### Generating the repetitive part

Starting another day also involves creating a folder and connecting the same functions. For that, I use:

{% highlight sh %}
go run ./cmd/generator -y 2024 -d 5
{% endhighlight %}

The [generator](https://github.com/manoamaro/advent-of-code/blob/main/cmd/generator/main.go) uses an embedded Go text template to create `cmd/2024/05/main.go`. If the folder already exists, it skips it instead of overwriting the solution.

This only prepares the structure. It doesn't generate a solution or know how the input should be parsed. I still decide those things after reading the puzzle.

### Keeping the helpers small

The reusable packages cover things like sets, queues, grids, slice operations, and mathematical helpers. The challenge runner lives under `internal/aoc`, while older solutions can still use a compatibility wrapper at `pkg/aoc`.

That wrapper helps with moving the code without changing every old solution at once. It doesn't turn the internal runner into a standalone library for other projects; the wrapper still depends on this repository's internal package.

I find it useful to keep the boundary practical. A queue or a set can be shared across many puzzles. A struct describing one day's ordering rules probably belongs next to that day's solution. Having a shared package isn't a reason to move every small function into it.

### Samples and automated tests

The runner provides `TestPart1` and `TestPart2` methods for checking sample files. The `--test` flag enables those checks when the day command calls them. This is convenient while working through a puzzle, but it isn't the same as running Go's test suite.

In the current implementation, a failed sample check writes an error to the log. It doesn't fail a `testing.T` or guarantee a non-zero process exit. Also, `--test` doesn't replace the normal input run; the day program still calls `Run()`. To work without a network request, I need a local input file or an existing cache as well.

For repeatable checks, the helper packages have ordinary `_test.go` files. The repository's [CI workflow](https://github.com/manoamaro/advent-of-code/blob/main/.github/workflows/ci.yml) runs vet, tests, and a build of the outer runner. Locally, the Makefile provides the same shortcuts:

{% highlight sh %}
make vet
make test
make run y=2024 d=05 p=1 debug=1 input=path/to/input.txt
{% endhighlight %}

Before running these commands, I check the Go version required by `go.mod` and install the dependencies with `go mod download`. The source file is the reference for the required toolchain when documentation and configuration differ.

### What I would improve next

The next improvements I would make are stricter argument validation, HTTP and cache error handling, and sample checks that can actually fail an automated run. The runner also recovers panics by logging them, so its exit status needs attention before I rely on it as a reliable signal of success.

Even with those limitations, the structure keeps the repetitive work in one place: choosing a day, loading input, parsing it, and running each part. The puzzle-specific code stays in its own folder. That's the balance I want from this toolkit: enough shared code to make the next solution easier to start, while leaving room to solve each problem differently.
