---
title: 'Codility Challenge: Genomic Range Query'
description: A solution to the Genomic Range Query problem, covering how DNA prefix sums can be used to answer multiple queries efficiently.
category_label: Algorithms
date: 2015-10-27 00:00:00 Z
tags:
- codility
- challenge
- genomicRangeQuery
- solution
- ruby
layout: post
published_at: 22/10/2015
---

This was one of the toughest challenges for me. My first solution passed all the tests, but after analysing it more closely, I realised it probably wasn't the intended approach.

{% highlight ruby %}
def solution(s, p, q)
  nucleotides = {
      'A' => 1,
      'C' => 2,
      'G' => 3,
      'T' => 4
  }
  result = []
  for i in 1..p.size do
    slice = s[p[i - 1]..q[i - 1]]
    nucleotides.each do |key, value|
      if slice.include? key
        result << value
        break
      end
    end
  end
  return result
end
{% endhighlight %}

The original Codility result link is no longer available. The [Genomic Range Query challenge](https://app.codility.com/programmers/lessons/5-prefix_sums/genomic_range_query/) is still available.

My first solution didn't use the prefix-sum technique that I think the lesson was teaching. Its time complexity is O(4 × M × N), where N is the string length and M is the number of queries. I tried to find a prefix-sum solution on my own, but couldn't work one out. After researching and analysing several existing solutions, I came up with this implementation.

{% highlight ruby %}
def solution(s, p, q)

  n = s.size
  prefix_sums = Hash.new { |h,k| h[k] = Array.new(n + 1, 0) }
  nucleotides = {
      'A' => 1,
      'C' => 2,
      'G' => 3,
      'T' => 4
  }

  nucleotides.each do |key, value|
    for i in 1..n
      prefix_sums[key][i] = prefix_sums[key][i - 1]
      prefix_sums[key][i] += 1 if s[i - 1] == key
    end
  end

  result = []

  for i in (1..p.size) do
    nucleotides.each do |key, value|
      if prefix_sums[key][p[i - 1]] != prefix_sums[key][q[i - 1] + 1]
        result << value
        break
      end
    end
  end

  return result
end
{% endhighlight %}

Now a brief explanation about this algorithm. The first part calculates prefix sums. Instead of keeping a separate variable for each letter, it creates a hash that stores an array of sums for each nucleotide.

{% highlight ruby %}
def solution(s, p, q)

  n = s.size
  prefix_sums = Hash.new { |h,k| h[k] = Array.new(n + 1, 0) }
  nucleotides = {
      'A' => 1,
      'C' => 2,
      'G' => 3,
      'T' => 4
  }

  nucleotides.each do |key, value|
    for i in 1..n
      prefix_sums[key][i] = prefix_sums[key][i - 1]
      prefix_sums[key][i] += 1 if s[i - 1] == key
    end
  end
{% endhighlight %}

The hash is created with a block that is called whenever a missing key is accessed. It creates an array of the required size, initialized to zero. After that, for each nucleotide in the hash, an array of prefix sums is created for each letter. Using the string of the example (CAGCCTA), the hash of prefix sums will be like this:

{% highlight ruby %}

{
  "A"=>[0, 0, 1, 1, 1, 1, 1, 2],
  "C"=>[0, 1, 1, 1, 2, 3, 3, 3],
  "G"=>[0, 0, 0, 1, 1, 1, 1, 1],
  "T"=>[0, 0, 0, 0, 0, 0, 1, 1]
}

{% endhighlight %}

As you can see, when there is a difference between two values in an array, there is a letter in there. For example, in the position 2 (0 index based) there is a letter "G", because `prefix_sums["G"][2 + 1] != prefix_sums["G"][2]`. Now it's easier to check whether a given range contains a nucleotide.

The rest of the algorithm builds the result iterating over the `p` and `q` (`p.size == q.size`). For each query, the algorithm checks the nucleotides in order of impact factor, from the lowest (`A`) to the highest (`T`), to find the first one present in the range. If a letter is found (as explained before, if there is a difference between the prefix sums array in given indexes), simply push this result to the `result` array and go to the next range.

{% highlight ruby %}

result = []

for i in (1..p.size) do
  nucleotides.each do |key, value|
    if prefix_sums[key][p[i - 1]] != prefix_sums[key][q[i - 1] + 1]
      result << value
      break
    end
  end
end

return result
{% endhighlight %}

This reduces the time complexity from O(4 × M × N) to O(4 × N + 4 × M). Ignoring constant factors, that is O(N + M), which matches the expected complexity.

Other Codility challenges (the original shared solution links are no longer available):
{% include codility_challenges.html %}
