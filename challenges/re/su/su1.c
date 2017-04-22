#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>

void check_password(char *pass, char *root){
  long x = 0x646f;
  int i = 0;
  while(pass[i] != 0){
    long j, d = 1, c = (long)(pass[i]);
    for(j = 0; j <= i; j++) d *= c;
    x += (i+3)*d;
    i++;
  }
  if(x == 0xd25a2ad5){
    *root = 1;
  }
  else{
    printf("FAILURE\n");
    *root = 0;
  }
}

int main(int argc, char **argv)
{
  int root = 0;
  char pw[100];
  int i;
  for(i = 0; i < 100; i++){
    pw[i] = 0;
  }
  write(1,"Password: ",10);
  read(0,&pw,200);
  check_password(pw, (char *)&root);
  if(root) system("/bin/sh");
}
