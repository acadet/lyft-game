src=../src/

all: clean build

build:
	cp -r $(src)bower_components .
	cp -r $(src)css .
	cp -r $(src)fonts .
	cp -r $(src)imgs .
	cp -r $(src)js .
	cp -r $(src)sounds .
	cp $(src)index.html .

clean:
	rm -r bower_components
	rm -r css
	rm -r fonts
	rm -r imgs
	rm -r js
	rm -r sounds
	rm index.html