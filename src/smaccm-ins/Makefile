include ../../stack.mk

IVORY_FLAGS ?= --const-fold

# test: psas-recording-ivory-test
# test: all-sensors-ins-test
test: test-fmu24

test-fmu17: IVORY_FLAGS += --conf-file=fmu17.conf
test-fmu17: SRC_PREFIX = platform-fmu17/
test-fmu17: px4-sensor-fusion-test

test-fmu24: IVORY_FLAGS += --conf-file=fmu24.conf
test-fmu24: SRC_PREFIX = platform-fmu24/
test-fmu24: px4-sensor-fusion-test

.PHONY: psas-recording-ivory-test
psas-recording-ivory-test: IVORY_FLAGS += --no-sanity-check
psas-recording-ivory-test: default
	stack exec -- psas-recording-test-gen \
			--src-dir=psas-recording-ivory-test \
			$(IVORY_FLAGS)
	make -C psas-recording-ivory-test

.PHONY: psas-recording-ivory-test-clean
psas-recording-ivory-test-clean:
	-rm -rf psas-recording-ivory-test

.PHONY: px4-sensor-fusion-test
px4-sensor-fusion-test: default
	stack exec -- px4-sensor-fusion-test-gen \
			--src-dir=$(SRC_PREFIX)px4-sensor-fusion-test
			--no-sanity-check \
			$(IVORY_FLAGS)
	make -C $(SRC_PREFIX)px4-sensor-fusion-test

.PHONY: px4-sensor-fusion-test-clean
px4-sensor-fusion-test-clean:
	-rm -rf px4-sensor-fusion-test

.PHONY: all-sensors-ins-test
all-sensors-ins-test: default
	stack exec -- all-sensors-ins-test-gen \
			--src-dir=$@ \
			--no-sanity-check \
			$(IVORY_FLAGS)
	make -C $@

.PHONY: all-sensors-ins-test-clean
all-sensors-ins-test-clean:
	-rm -rf all-sensors-ins-test

.PHONY: ins-filter-test
ins-filter-test: default
	stack exec -- ins-filter-test-gen --src-dir=$@ $(IVORY_FLAGS)
	make -C $@
	./$@/filter_test | python plotter.py

.PHONY: ins-filter-test-clean
ins-filter-test-clean:
	-rm -rf ins-filter-test

.PHONY: ins-mag-bias-test
ins-mag-bias-test: default
	stack exec -- ins-mag-bias-test-gen --src-dir=$@ $(IVORY_FLAGS)
	make -C $@
	./$@/mag_bias_test

.PHONY: ins-mag-bias-test-clean
ins-mag-bias-test-clean:
	-rm -rf ins-mag-bias-test

clean: psas-recording-ivory-test-clean
clean: px4-sensor-fusion-test-clean
clean: all-sensors-ins-test-clean
clean: ins-filter-test-clean
clean: ins-mag-bias-test-clean
