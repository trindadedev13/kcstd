#include "kcstd/char.h"

#include "kcstd/types.h"

bool is_space(char c) {
  return ((c == ' ') || (c == '\n') || (c == '\t'));
}

bool is_digit(char c) {
  return ((c >= '0') && (c <= '9'));
}

bool is_alpha(char c) {
  return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'));
}

int to_lower(char c) {
  return c | 32;
}