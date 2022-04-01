extern void __cdecl printf (const char *str, ...);

int main() {
    printf("This is the test %c %s %x but %o with %%\n", 'I', "will not", 0xDE, 31, 5);
    return 0;
}

