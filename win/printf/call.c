extern void __cdecl printf (const char *str, ...);

int add (int a, int b) {
    return a + b;
}

int main() {
    printf ("This is the test %c %s %x but %o with %%\n", 'I', "will not", 0xDE, 31, 5);
    int a = 3, b = 7;
    int c = add (3, 7);
    printf ("And number is %d %d\n", c, c);
    return 0;
}

