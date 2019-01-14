#ifndef LIBBASE58_H
#define LIBBASE58_H

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#define ALPH int8_t type

extern bool b58tobin(void *bin, size_t *binszp, const char *b58, size_t b58sz, ALPH);
extern bool b58enc(char *b58, size_t *b58sz, const void *bin, size_t binsz, ALPH);

#define BTCMAP 0
#define XRPMAP 1

#endif
