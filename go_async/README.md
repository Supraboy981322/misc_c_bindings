# very basic async using Golang's goroutines

## building

```
go build -buildmode=c-archive -o async.a async.go
```

## Usage

You must define both functions `fn_callback` (calls function with no params) and `void_ptr_fn_callback` (calls function with a param type of `void*`)

A Zig example that uses the `void_ptr_fn_callback` to pass data as a param can be found [here](./example/zig/) 

basic C example (`fn_callback` so no data passed)
```c
#include <stdio.h>
#include <unistd.h>
#include "async.h"

typedef void (*call_fn)(void);
typedef void (*call_fn_data)(void* data);

void fn_callback(void* fn) {
  call_fn f = (call_fn)fn;
  f();
}

void void_ptr_fn_callback(void* fn, void* data) {
  call_fn_data f = (call_fn_data)fn;
  f(data);
}

void func(void) {
  printf("async starting (waiting 1 second)\n");
  sleep(1);
  printf("async ending\n");
}

int main(void) {
  printf("calling async"); 
  async_void((void*)func);
  printf("called (waiting 2 seconds to exit)\n");
  sleep(2);
  return 0;
}
```
