#include <kcstd/io.h>
#include <kcstd/memory.h>
#include <kcstd/time.h>
#include <kcstd/types.h>

struct people {
  string name;
};

int main(int argc, string argv[]) {
  printf("argc: %d\n", argc);
  for (int i = 0; i < argc; ++i) {
    printf("argv:%d:%s\n", i, argv[i]);
  }

  struct people* me = memory_alloc(sizeof(struct people));
  if (me == null) {
    printf("Failed to allocate memory for 'struct people me'\n");
    return 1;
  }
  me->name = "Aquiles Trindade";

  printf("My name is %s\n", me->name);

  memory_free(me);

  // str_len(src)
  printf("ola size: %d\n", str_len("Ola"));

  // str_copy_lmt(src, dest, lmt)
  string cc = "gcc";
  size_t tt = str_len(cc) + 1;
  string cp = memory_alloc(tt);
  str_copy_ofs(cp, cc, 2);

  printf("%s\n", cp);

  // str_cat(src, new)
  string text_a = "Hello, ";
  string text_b = "World!";
  string text = memory_alloc(str_len(text_a) + str_len(text_b));
  str_cat(text, text_a);
  str_cat(text, text_b);
  printf("%s\n", text);

  // str_equals(src, compare)
  bool ba = str_equals(text_a, "Hello, ");
  printf("text_a Equals \"Hello, \" ? : %s\n", ba ? "true" : "false");

  bool bb = str_equals(text_b, "Hello, ");
  printf("text_b Equals \"Hello, \" ? : %s\n", bb ? "true" : "false");

  memory_free(text);

  // Write hi in main.txt
  file* txt = file_open("main.txt", FILE_MODE_WRITE);
  if (txt == null) {
    printf("Failed to open main.txt.\n");
    return 1;
  }
  file_write(txt, "hi", str_len("hi"));
  file_close(txt);

  // read 128 bytes in main.txt
  file* rtxt = file_open("main.txt", FILE_MODE_READ);
  if (rtxt == null) {
    printf("Failed to open main.txt.\n");
    return 1;
  }
  string dest = memory_alloc(1024);
  file_read(rtxt, dest, 1024);
  printf("File content: %s\n", dest);

  time_spec ts;
  clock_get_time(CLOCK_REALTIME, &ts);
  start_rand(ts.sec);
  int64_t rand_1 = rand();
  printf("1st Rand: %d\n", rand_1);
  printf("1st Time: %d\n", ts.sec);

  start_rand(time(null));
  int64_t rand_2 = rand();
  printf("2nd Rand: %d\n", rand_2);
  printf("2nd Time: %d\n", time(null));

  return 0;
}