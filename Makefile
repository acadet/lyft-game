src=../src/

build:
	cp -r $(src)bower_components .
	cp -r $(src)css .
	cp -r $(src)fonts .
	cp -r $(src)imgs .
	cp -r $(src)js .
	cp -r $(src)sounds .
	cp $(src)index.html .