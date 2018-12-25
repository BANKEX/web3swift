#ifndef LIBBASE58_H
#define LIBBASE58_H

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#define ALPH int8_t type

extern bool (*b58_sha256_impl)(void *, const void *, size_t);

extern bool b58tobin(void *bin, size_t *binszp, const char *b58, size_t b58sz, ALPH);
extern int b58check(const void *bin, size_t binsz, const char *b58, size_t b58sz, ALPH);

extern bool b58enc(char *b58, size_t *b58sz, const void *bin, size_t binsz, ALPH);
extern bool b58check_enc(char *b58c, size_t *b58c_sz, uint8_t ver, const void *data, size_t datasz, ALPH);

#define BTCMAP 0
#define XRPMAP 1

#endif
