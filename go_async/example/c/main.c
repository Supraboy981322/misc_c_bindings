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
