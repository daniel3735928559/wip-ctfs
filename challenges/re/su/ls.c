#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>

#define PORT "1278"

int check_password(char *pass){
  long x = 0x646f;
  int i = 0;
  while(pass[i] != 0){
    long j, d = 1, c = (long)(pass[i]);
    for(j = 0; j <= i; j++) d *= c;
    x += (i+3)*d;
    i++;
  }
  if(x == 0xd25a2ad5){
    printf("access granted\n");
    system("ls /etc");
    printf("lol you thought it was going to be /bin/sh");
    return 0;
  }
  else{
    printf("FAILURE\n");
  }
  return x;
}

int read_password(char *pw){
  char buf[32];
  printf("reading password...\n");
  strcpy(buf, pw);
  return check_password(buf);
}

int main(int argc, char **argv)
{
  return read_password(argv[1]);
}
