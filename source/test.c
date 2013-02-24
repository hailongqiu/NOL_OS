

void io_hlt(void);

void test_main(void)
{
fin:
    io_hlt();
    goto fin;
}
