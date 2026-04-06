/*
 * Recursive Fibonacci sequence printer.
 * Usage: ./fibonacci <n>
 * Prints the first n Fibonacci numbers (F_0, F_1, ..., F_{n-1}).
 * Example: ./fibonacci 5  =>  0 1 1 2 3
 */

#include <iostream>
#include <cstdlib>

// Recursive Fibonacci: F(0)=0, F(1)=1, F(n)=F(n-1)+F(n-2)
int fib(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    return fib(n - 1) + fib(n - 2);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <n>\n";
        std::cerr << "  Prints the first n Fibonacci numbers (0, 1, 1, 2, 3, 5, ...)\n";
        return 1;
    }

    int n = std::atoi(argv[1]);
    if (n < 0) {
        std::cerr << "Error: n must be non-negative.\n";
        return 1;
    }

    std::cout << "Fibonacci sequence (first " << n << " numbers): ";
    for (int i = 0; i < n; ++i) {
        std::cout << fib(i);
        if (i < n - 1) std::cout << " ";
    }
    std::cout << "\n";

    return 0;
}
