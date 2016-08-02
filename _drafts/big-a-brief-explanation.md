---
title: Big O - A brief explanation
date: 2016-08-02 02:50:28.011000000 Z
tags:
- computer science
- big o
- time
- space
- algorithms
- complexity
layout: post
---

One of the most important concept that I saw in all coding challenges (and some companies use theses challenges for hiring) is the **Big-O**. Basically, it's used to estimate the complexity of an algorithm, "calculating" an approximated time and space that this algorithm will need to finish it's job, based on the size of the input. In this post I'm going to explain the concepts of Big-O and some examples of how to "calculate" it.


### What is Big-O? Time and Space Complexity

As I introduced before, Big-O can represent the time and space complexity, that is, how long in time and how much in space an algorithm needs to finish it's execution entirely, from the size or range of the algorithm's input. The notation is **O(N)**, which in this case means that the time and/or space is the same as the size **N** of the input. Take this simple algorithm for example:

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

The first algorithm simply takes 2 arguments, the *start* and *finish* of a range, and sums every integer number between this range. As you can see, as bigger the range, bigger the *for* is going to loop, and longer the execution will be. So, in this case, we can say that the time complexity of this algorithm depends on the size of the range, **O(finish-start)**, or simply **O(N)**, expressing that the time will increase the same amount the size of the range increases. The second algorithm, however, will always execute one instruction and return the value, independently of the input. In this case, we can assume that the complexity is merely **O(1)**, which means that the algorithm's runtime is always constant.

The *Space Complexity* is a parallel concept of *Time Complexity*, where you will estimate how much memory that algorithm will take to complete it's execution. Shortly, if your algorithm needs to instantiate an array of size *N*, then the space complexity will be **O(N)**. In the first example, both functions do not instantiate new variables and keep references for them, so the *Space Complexity* will be **O(1)**.

Now take for example the algorithm below:

{% highlight ruby %}

  # Calculate de sum of integers from 0 to max
  def sum(max)
    return 0 if max == 0
    return max + sum(max - 1)
  end

{% endhighlight %}

The *Time Complexity* of this function is **O(N)**, because this function will run *max* times recursively. But each time the function is called, it's added to the stack, consuming memory. So, the *Space Complexity* of this algorithm is also **O(N)**.


### Estimating Big-O

**O(N)** or **O(1)** are not the only possibilities of a  time complexity. For example, taking the algorithm below, witch with the given array of numbers, prints all permutations of 2.

{% highlight ruby %}

  # Prints all permutations of 2
  def permutations(array)
    for i in (0...array.size)
      for j in (0...array.size)
        puts ("#{i}, #{j}")
      end
    end
  end

{% endhighlight %}

This algorithm runs 2 nested *fors*, one inside the other. So, for every item in the array, the algorithm will run N times, for N = size of array. This will result in a time complexity of **O(N*N)**, or **O(N^2)**. If there were another nested *for*, the Big-O would be *O(N^3)*.

But, when the algorithm has 2 or more *fors*, but they are not nested, the time will not be exponential. For example, the 

{% highlight ruby %}

  def prefix_sum(array)
    result = Array.new array.size + 1, 0
    for i in (1..array.size)
      result[i] = result[i - 1] + array[i - 1]
    end
    result
  end

{% endhighlight %}


![](/images/big-o-post/f23nuh.jpg)



#### References
- [Book Cracking the Coding Interview 6th Edition, Gayle Laakmann McDowell.](http://www.amazon.com/gp/product/0984782850)
- [Book Introduction to the Theory of Computation 3rd Edition, Michael Sipser.](http://www.amazon.com/Introduction-Theory-Computation-Michael-Sipser/dp/113318779X)
