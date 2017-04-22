#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>

void check_password(char *pass, char *root){
  if(strcmp(pass,"SOOPERSEEKRITP455W00RD!!11!")){
    *root = 1;
  }
  else{
    printf("FAILURE\n");
    *root = 0;
  }
}

int main(int argc, char **argv)
{
  char root = 0;
  char pw[100];
  int i;
  for(i = 0; i < 100; i++){
    pw[i] = 0;
  }
  write(1,"Password: ",10);
  read(0,&pw,200);
  check_password(pw, &root);
  if(root) system("/bin/sh");
}
