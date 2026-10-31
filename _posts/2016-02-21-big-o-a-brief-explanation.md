---
title: Big O - A brief explanation
description: A practical introduction to Big-O, time and space complexity, and prefix sums using Ruby examples.
category_label: Algorithms
date: 2016-02-21 00:00:00 Z
tags:
- computer science
- big o
- time
- space
- algorithms
- complexity
layout: post
---

One of the most important concepts that I have seen in coding challenges (and some companies use these challenges for hiring) is **Big-O**. Basically, it helps us describe how the time or space an algorithm needs grows as its input gets bigger. In this post I'm going to explain the concept with a few examples of how to estimate it.

### What is Big-O? Time and Space Complexity

Big-O describes an upper bound on growth as the input gets large. It doesn't tell us the exact number of seconds or bytes an algorithm will use: those depend on the implementation and the machine. Instead, it helps us compare how the amount of work or memory changes with the input size. We should also say which case we're considering; the examples below describe the worst case unless mentioned otherwise.

Take these two functions, for example:

{% highlight ruby %}
def sum_range(start, finish)
  result = 0
  for i in (start...finish)
    result += i
  end
  return result
end

def sum(num1, num2)
  return num1 + num2
end
{% endhighlight %}

The first function sums the integers from `start` up to, but not including, `finish`. If `finish >= start`, let **N** be the size of the range, `finish - start`. The loop runs N times, so its time complexity is **O(N)**. The second function performs one addition regardless of the range size, so we describe its time complexity as **O(1)**, or constant time. For these examples, I'm treating arithmetic on the numbers as constant-time operations.

*Space complexity* is a similar concept, but it describes how the memory needed by an algorithm grows. Both functions above use a fixed number of local variables, so their **auxiliary space** is **O(1)**. Auxiliary space is the extra space used by the algorithm, excluding the input and, when stated separately, the output.

Now take this recursive function:

{% highlight ruby %}
# Calculate the sum of integers from 0 to max, for max >= 0
def sum_recursive(max)
  return 0 if max == 0
  return max + sum_recursive(max - 1)
end
{% endhighlight %}

If N is `max`, the function makes N + 1 calls, including the call for zero. Its time complexity is **O(N)**. Each unfinished call also occupies a stack frame, so the auxiliary space is **O(N)**. In practice, a large input can exceed Ruby's call-stack limit; an iterative version avoids that growing stack.

### Estimating Big-O

**O(N)** and **O(1)** are not the only possibilities. For example, the algorithm below prints every ordered pair of values from an array:

{% highlight ruby %}
def print_pairs(array)
  for i in (0...array.size)
    for j in (0...array.size)
      puts "#{array[i]}, #{array[j]}"
    end
  end
end
{% endhighlight %}

For every one of the N items, the inner loop runs N times. So, it prints N × N pairs and has **O(N²)** time complexity. This includes pairs with the same element and both orders of different elements. The loop itself uses **O(1)** auxiliary space, assuming each value is printed without storing all pairs. The output has N² pairs; storing them would require **O(N²)** space. Actual printing time can also depend on the length of each value's text.

Having two loops doesn't always mean quadratic time. If the loops run one after the other, we add their work instead of multiplying it:

{% highlight ruby %}
def print_twice(array)
  for item in array
    puts item
  end
  for item in array
    puts item
  end
end
{% endhighlight %}

Each loop runs N times, giving **O(N + N)**, or **O(N)** after dropping the constant factor. On the other hand, if two independent arrays have sizes N and M, one pass over each is **O(N + M)**. A nested loop that visits every combination is **O(N × M)**; we can't assume the arrays have the same size.

A loop inside another loop isn't automatically quadratic either. We need to count how many times the inner work actually runs. For example, if each step cuts the remaining search range in half, there are **O(log N)** steps. Binary search does this on a sorted array: it checks the middle value and continues in at most one half. Iterative binary search uses **O(1)** auxiliary space.

### A prefix sum example

Let's go back to an array and calculate its prefix sums:

{% highlight ruby %}
def prefix_sum(array)
  result = Array.new(array.size + 1, 0)
  for i in (1..array.size)
    result[i] = result[i - 1] + array[i - 1]
  end
  return result
end
{% endhighlight %}

For `[2, 3, 1]`, this returns `[0, 2, 5, 6]`. Each entry contains the sum of the elements before that index. The function allocates an array of N + 1 values and fills it in one pass, so its time complexity is **O(N)** and its output space is **O(N)**. Apart from the returned array, it uses **O(1)** auxiliary space.

Why is this useful? Once we have the prefix sums, the sum of an inclusive range from `left` to `right` is `result[right + 1] - result[left]`. Each range query then takes **O(1)** time. For M queries, building the array and answering them takes **O(N + M)** time, plus **O(N)** space for the prefix array and **O(M)** if we store the answers. I used the same idea for counting nucleotides in my [Genomic Range Query post]({{ '/2015/10/27/codility-challenge-genomic-range-query.html' | relative_url }}).

### A few things to remember

When estimating complexity, first decide what N represents and which case you are analysing. Count how often the work runs, add consecutive parts, and multiply for nested work when the inner part runs in full each time. Then simplify the expression: **O(2N + 3)** becomes **O(N)**, and **O(N² + N)** becomes **O(N²)** as N grows.

Big-O is an upper bound, so saying an algorithm is O(N²) doesn't by itself prove that it always needs quadratic time. It also doesn't replace measurement: constants, memory use, input shape, and implementation details can matter for real inputs. I find it most useful as a way to understand how a solution will scale before testing it.

#### References

- [MIT OpenCourseWare: Asymptotic Complexity](https://ocw.mit.edu/courses/6-006-introduction-to-algorithms-fall-2011/resources/recitation-1-asymptotic-complexity-peak-finding/)
- [Cracking the Coding Interview, 6th Edition](https://www.crackingthecodinginterview.com/)
- [Introduction to the Theory of Computation](https://www.cengage.com/c/introduction-to-the-theory-of-computation-3e-sipser/)
