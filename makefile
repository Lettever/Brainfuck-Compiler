all:
	nim c --verbosity:0 -o:bfc main.nim

examples: all
	@for file in examples/*.bf; do \
		if [ -f "$$file" ]; then \
			echo "=== $$file ==="; \
			./bfc "$$file"; \
			echo ""; \
		fi \
	done
	