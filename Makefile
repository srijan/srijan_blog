
all: folders
	hugo

clean:
	rm -r public

server: folders
	hugo server -w --buildDrafts

folders:
	mkdir -p static

