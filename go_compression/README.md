# a C binding for various Go compression libraries

Basic functionality (compress and decompress C strings).

---

### for a usage example (in Zig), see [the examples directory](./example/README.md)

---

## compression types
- gzip (Go standard library)
- zlib (Go standard library)
- brotli (github.com/google/brotli/go/cbrotli)

## Dependencies

- libbrotlicommon
- libbrotlidec
- libbrotlienc

## compiling the C headers and object

Requires Go

```sh
go build -buildmode=c-archive -o compress.a compress.go
```
