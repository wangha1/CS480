# This function computes and returns the n'th Fibonacci number.
def fib(n):
    f0 = 0
    f1 = 1
    i = 0
    while i < n:
        fi = f0 + f1
        f0 = f1
        f1 = fi
        i = i + 1

    return f0

# This function computes and returns the n'th Fibonacci number.
				# This function computes and returns the n'th Fibonacci number.


fib(0)
fib(1)
fib(2)
fib(3)
fib(4)
fib(5)
