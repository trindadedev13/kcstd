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

size_t file_write(const file* file, const void* buf, size_t len) {
  if (file == null || file->fd < 0 || buf == null)
    return 0;

  size_t bytes = write(file->fd, buf, len);
  return bytes < 0 ? 0 : (size_t)bytes;
}

size_t file_read(const file* file, const void* dest, size_t count) {
  if (file == null || file->fd < 0 || dest == null)
    return 0;

  size_t bytes = read(file->fd, dest, count);
  return bytes < 0 ? 0 : (size_t)bytes;
}

void file_close(file* fl) {
  if (fl == null) return;
  if (fl->fd >= 0) {
    __ASM_CLOSE__(fl->fd);
    fl->fd = -1;
  }
  memory_free(fl);
}