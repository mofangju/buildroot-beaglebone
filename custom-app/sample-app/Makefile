 ### 
 ### I think it's not worth to make such a small project
 ### modular. So this is a simple gnu Makefile...
 ###
 
.DELETE_ON_ERROR:
.PHONY: install clean all
 
all: sample-app 
 
sample-app: sample-app.c
	$(CC) -g -Wall $(CFLAGS) $(LDFLAGS) $< -o $@
 
install: sample-app
	install -D -m 0755 sample-app $(DESTDIR)/usr/bin/sample-app
 
clean:
	-$(RM) sample-app *~ \#*\#

