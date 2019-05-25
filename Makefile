default: test run
	-@echo 'Done!'

run:
	-@stack run

test:
	-@clear
	-@stack test

clean:
	-@stack clean

.PHONY: default test run clean
