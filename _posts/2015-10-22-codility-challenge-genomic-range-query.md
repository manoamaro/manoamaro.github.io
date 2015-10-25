---
layout: post
title: 'Codility Challenge: Genomic Range Query'
published_at: 22/10/2015
---

This challenge is in the list of the toughest challenges for me. I wrote a code that got 100% on tests, but with a more detailed analysis, it's not the expected answer.

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

You can check the results [here](https://codility.com/demo/results/trainingAZJBGW-NSR)

In this solution, I didn't use what I think the lesson expected us to implement (prefix sum technique). So, I started to try to find a solution using prefix sum, but I couldn't find anything by my own. So, I searched for the existing solutions, and after analyzing a lot of different ones, I came up with this implementation.

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
