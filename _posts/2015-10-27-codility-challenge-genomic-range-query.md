---
layout: post
title: 'Codility Challenge: Genomic Range Query'
published_at: 22/10/2015
tags:
  - codility
  - challenge
  - programming
  - ruby
---

This challenge is in the list of the toughest challenges for me. I wrote a code that got 100% on tests, but with a more detailed analysis, I believe it's not the expected answer.

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

In this solution, I didn't use what I think the lesson expected us to use (prefix sum technique). And calculating the complexity it will give us O(m*4*n). So, I started to try to find a solution using prefix sum, but I couldn't find anything by my own. Then I searched for some existing solutions, and after analyzing a lot of different ones, I came up with this implementation.

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

Now a brief explanation about this algorithm. The first part is the prefix sum calculation of the values. But instead of keeping an array of prefix sums, it creates a hash and store an array of sums for each letter.

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

The hash is created with an block that is called everytime an empty index is accessed, creating a new array with predefined size and initial value of zero. After that, for each nucleotide in the hash, an array of prefix sums is created for each letter. Using the string of the example (CAGCCTA), the hash of prefix sums will be like this:

{% highlight ruby %}

{
  "A"=>[0, 0, 1, 1, 1, 1, 1, 2],
  "C"=>[0, 1, 1, 1, 2, 3, 3, 3],
  "G"=>[0, 0, 0, 1, 1, 1, 1, 1],
  "T"=>[0, 0, 0, 0, 0, 0, 1, 1]
}

{% endhighlight %}

As you can see, when there is a difference between two values in an array, there is a letter in there. For example, in the position 2 (0 index based) there is a letter "G", because `prefix_sums["G"][2 + 1] != prefix_sums["G"][2]`. Now it's less complex to find an letter in a given position.

The rest of the algorithm builds the result iterating over the `p` and `q` (`p.size == q.size`). For each nucleotide, verify if in the given range from `p` and `q` there is a letter, from the lowest factor ("A") to the highest factor ("T"). If a letter is found (as explained before, if there is a difference between the prefix sums array in given indexes), simply push this result to the `result` array and go to the next range.

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

With this algorithm, the complexity drops from `O(m*4*n)` to `O(4*n + 4*m)`. Ruling out the constants, `O(n + m)` matches the challenge's expected complexity.
