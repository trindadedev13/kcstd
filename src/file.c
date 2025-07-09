#include "kcstd/io.h"

#include "kcstd/memory.h"
#include "kcstd/string.h"
#include "kcstd/types.h"

file* file_open(string filename, file_open_mode mode) {
  file* fl = memory_alloc(sizeof(file));
  if (fl == null) {
    printf("Failed to allocated memory to open %s.\n", filename);
    return null;
  }
  fl->filename = filename;
  int flags;
  int perm = 0;
  if (mode == FILE_MODE_READ) {
    flags = O_RDONLY;
  } else if (mode == FILE_MODE_WRITE) {
    flags = O_CREAT | O_WRONLY | O_TRUNC;
    perm = PERM_RWR_R_R;
  }
  int fd = __ASM_OPENAT__(-100, filename, flags, perm);
  if (fd < 0) {
    return null;
  }
  fl->fd = fd;
  return fl;
}

void file_close(file* fl) {
  if (fl == null) return;
  if (fl->fd >= 0) {
    __ASM_CLOSE__(fl->fd);
    fl->fd = -1;
  }
  memory_free(fl);
}