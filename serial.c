#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include	<time.h>
//#include <sys/time.h>

#define MESSAGE_SIZE_PER_LINE 4+1
#define BUFSIZE 102
#define ENCODED_FILE_SIZE 15360

char * decode(char* line){
   
   const char delm[2] = ",";
   char *token,*message;
   int i = 0;
   message = malloc(MESSAGE_SIZE_PER_LINE);
   /* get the first character*/
   token = strtok(line, delm);
   strtok(NULL, delm);
   /* walk through other characters */
   while( token != NULL ) {
      message[i++] = token[0];
      token = strtok(NULL, delm);
   }
   message[MESSAGE_SIZE_PER_LINE-1] = '\0';
   return message;
}
char* getFileLines(){
   char *buffer,*allMessage,*message, chr = 0;
   int string_size, read_size, newline = 0, i = 0;
   struct filefeatures* f; //file features to return
   FILE *fileIn = fopen("encodedfile.txt", "r");
   FILE *fileOut = fopen("decodedfile.txt", "w");
   buffer =(char*) malloc(BUFSIZE);
   allMessage=(char*) malloc(ENCODED_FILE_SIZE*(MESSAGE_SIZE_PER_LINE-1));
   if (fileIn)
   {
      //count newlines
       while (fgets(buffer,BUFSIZE, fileIn) != NULL){
       
          message = decode(buffer);
          fputs(message,fileOut);
          //strcpy(&allMessage[newline*(MESSAGE_SIZE_PER_LINE-1)],message);
          //newline++;
       	free(message);
       }
       //allMessage[ENCODED_FILE_SIZE*(MESSAGE_SIZE_PER_LINE-1)]= '\0';
       //printf("%s\n",allMessage);
       fclose(fileIn);
       fclose(fileOut);
    }
    free(buffer);
    return allMessage;
}
/*void writeFile(char* message){
    
    fprintf(file,message);
    fclose(file); 	
}*/
int main (int argc,char* args[]){
	char* message;
	//struct timeval stop,start;
	float elapsed;
	//gettimeofday(&start,NULL);
	clock_t start = clock();
	message= getFileLines();
	//writeFile(message);
	
	//gettimeofday(&stop,NULL);
	//elapsed =(stop.tv_sec-start.tv_sec)*1000.0f+(stop.tv_usec-start.tv_usec)/1000.0f;
//	printf("Code executed in %f milliseconds.\n",elapsed);
	clock_t end = clock();
	clock_t millis = end - start;

	
	printf("Code executed in %f milliseconds.\n",(double) millis / (double)CLOCKS_PER_SEC * 1000.0);
	
	free(message);
	
}
