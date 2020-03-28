
all: folders
	hugo

clean:
	rm -r public

server: folders
	hugo server -w

folders:
	mkdir -p static

