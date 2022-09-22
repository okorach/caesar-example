SHELL := /bin/bash

FONT_BOLD := `tput bold`
FONT_CYAN := `tput setaf 6`
FONT_RED := `tput setaf 1`
FONT_RESET := `tput sgr0`
TIS_ANALYZER := tis-analyzer
FILES := test_driver.c caesar.c
TIS_OPTS = -tis-config-load tis.json

.PHONY: test cov clean tis_l1 tis_l2 tis_l1_report tis_l2_report tis_l1_gui tis_l2_gui test1 test2 test-int report

all:
	@echo -e "$(FONT_CYAN)gcc -I. $(FILES) -o caesar && ./caesar$(FONT_RESET)"
	@gcc -I. $(FILES) -o caesar && ./caesar

cov:
	@echo -e "$(FONT_CYAN)gcc -I. -fprofile-arcs -ftest-coverage $(FILES) -o caesar && ./caesar$(FONT_RESET)"
	@gcc -I. -fprofile-arcs -ftest-coverage $(FILES) -o caesar && ./caesar
	@echo ""
	@echo -e "$(FONT_CYAN)gcov caesar.c $(FONT_RESET)"
	@gcov caesar.c

tis_l1_run:
	@echo -e "$(FONT_CYAN)$(TIS_ANALYZER) $(TIS_OPTS)$(FONT_RESET)"
	@$(TIS_ANALYZER) $(TIS_OPTS) -tis-config-select-by-name positive-shift
	@$(TIS_ANALYZER) $(TIS_OPTS) -tis-config-select-by-name negative-shift

tis_l1_gui:
	@echo -e "$(FONT_CYAN)$(TIS_ANALYZER) $(TIS_OPTS) -gui$(FONT_RESET)"
	@$(TIS_ANALYZER) $(TIS_OPTS) -tis-config-select-by-name main -gui | sed '/stack:.*main.c/q'

tis_l1: tis_l1_run report

tis_l2_run:
	@echo -e "$(FONT_CYAN)$(TIS_ANALYZER) $(TIS_OPTS) -D LEVEL2=1$(FONT_RESET)"
	@$(TIS_ANALYZER) $(TIS_OPTS) -tis-config-select-by-name generalized-shift -D LEVEL2=1

tis_l2_report: tis_l2_run report
	@echo -e "$(FONT_CYAN)$(TIS_ANALYZER) $(TIS_OPTS) -D LEVEL2=1$(FONT_RESET)"
	@$(TIS_ANALYZER) $(TIS_OPTS) -tis-config-select-by-name generalized-shift -D LEVEL2=1

tis_l2_gui: tis_l2_report
	@echo -e "$(FONT_CYAN)$(TIS_ANALYZER) -D LEVEL2=1  $(TIS_OPTS) -tis-report -gui$(FONT_RESET)"
	@$(TIS_ANALYZER) $(TIS_OPTS) -tis-config-select-by-name generalized-shift -D LEVEL2=1 -gui

tis_l2: tis_l2_gui

tis_l2_step2_run:
	@echo -e "$(FONT_CYAN)$(TIS_ANALYZER) $(TIS_OPTS) -tis-config-select-by-name generalized-string -D LEVEL2=1$(FONT_RESET)"
	@$(TIS_ANALYZER) $(TIS_OPTS) -tis-config-select-by-name generalized-string -D LEVEL2=1 -D LEVEL2_STEP2=1

tis_l2_step2_gui:
	@echo -e "$(FONT_CYAN)$(TIS_ANALYZER) $(TIS_OPTS) -tis-config-select-by-name generalized-string -D LEVEL2=1 -gui$(FONT_RESET)"
	@$(TIS_ANALYZER) $(TIS_OPTS) -tis-config-select-by-name generalized-string -D LEVEL2=1  -D LEVEL2_STEP2=1 -gui

tis_l2_step2: tis_l2_step2_run report

report:
	@printf "Compiling report from past executed tests:\n"
	@ls _results/*.json | sed 's/_results\.json//'
	@tis-report _results/
	@printf "\n\nCheck generated test report $(FONT_CYAN)tis_report.html$(FONT_RESET)\n\n"

break_build:
	@! cat _results/*_results.json|jq '{status: .alarms.status}'|grep -H '"status": "NOT OK"'

clean:
	@rm -rf a.out a.out.dSYM caesar caesar.dSYM *.gcov *.gcda *.gcno _results tis_report.html
