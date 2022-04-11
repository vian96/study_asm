// CODE WAS TAKEN FROM https://lawlessguy.wordpress.com/2015/12/27/a-music-macro-language-player-in-c/

// MMLPlayer
// by Jim Lawless
// MIT / X11 License
// See: http://www.mailsend-online.com/license2015.php
 
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <windows.h>
#include "psg.h"
 
void runscript(char *scriptname);
 
int main(int argc,char **argv) {
   printf("Music Macro Language Player\n");
   printf("by Jim Lawless - http://jiml.us\n\n");
   printf("This program uses the Macrotune libraries from\n");
   printf("http://www.posemotion.com/macrotune/\n\n");
 
   if(argc<2) {
      fprintf(stderr,"Syntax: mmlplayer script-file-name");
      return 1;
   }   
   runscript(argv[1]);
   return 0;
}
 
void runscript(char *scriptname) {
   char buff[1024];
   FILE *fp;
   char *p;
 
   fp=fopen(scriptname,"r");
   if(fp==NULL) {
      fprintf(stderr,"Cannot open script %s\n",scriptname);
      return;
   }
   while(fgets(buff,sizeof(buff)-1,fp)!=NULL) {
      p=strtok(buff,"\t\r\n ");
      if(!strcmp(p,"#")) {
         continue; 
      }
      else
      if(!strcasecmp(p,"echo")) {
         p=strtok(NULL,"\r\n");
         printf("%s\n",p);
      }
      else
      if(!strcasecmp(p,"volume")) {
         p=strtok(NULL,"\t\r\n");
         PSG_SetMasterVolume((float)atof(p));         
      }
      else
      if(!strcasecmp(p,"play")) {
         p=strtok(NULL,"\t\r\n");
         PSG_PlayMML(p,"","","");         
         while(PSG_IsPlayingMML())
            Sleep(500); // sleep and wait
      }
   }   
   fclose(fp);
   PSG_Terminate();
}
