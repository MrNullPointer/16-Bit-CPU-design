# Makefile for 16-Bit CPU Design
# Supports GHDL (open-source VHDL simulator)

GHDL ?= ghdl
GHDL_FLAGS = --std=02

SRC_DIR = src
TB_DIR  = tb

# Source files (order matters for dependencies)
SRCS = $(SRC_DIR)/alu.vhd \
       $(SRC_DIR)/register_file.vhd \
       $(SRC_DIR)/program_counter.vhd \
       $(SRC_DIR)/instruction_register.vhd \
       $(SRC_DIR)/instruction_memory.vhd \
       $(SRC_DIR)/data_memory.vhd \
       $(SRC_DIR)/stack_pointer.vhd \
       $(SRC_DIR)/mux2to1.vhd \
       $(SRC_DIR)/controller.vhd \
       $(SRC_DIR)/cpu_top.vhd

# Testbench files
TBS = $(TB_DIR)/alu_tb.vhd \
      $(TB_DIR)/register_file_tb.vhd \
      $(TB_DIR)/program_counter_tb.vhd \
      $(TB_DIR)/data_memory_tb.vhd \
      $(TB_DIR)/controller_tb.vhd \
      $(TB_DIR)/stack_pointer_tb.vhd \
      $(TB_DIR)/cpu_top_tb.vhd

# Testbench entity names
TB_ENTITIES = alu_tb register_file_tb program_counter_tb \
              data_memory_tb controller_tb stack_pointer_tb cpu_top_tb

.PHONY: all analyze test clean help

all: analyze

help:
	@echo "Usage:"
	@echo "  make analyze    - Compile all VHDL sources"
	@echo "  make test       - Run all testbenches"
	@echo "  make test-alu   - Run ALU testbench only"
	@echo "  make test-cpu   - Run CPU integration test only"
	@echo "  make clean      - Remove generated files"

analyze: $(SRCS) $(TBS)
	$(GHDL) -a $(GHDL_FLAGS) $(SRCS)
	$(GHDL) -a $(GHDL_FLAGS) $(TBS)

test: analyze
	@for tb in $(TB_ENTITIES); do \
		echo "=== Running $$tb ==="; \
		$(GHDL) -e $(GHDL_FLAGS) $$tb; \
		$(GHDL) -r $(GHDL_FLAGS) $$tb --stop-time=10000ns 2>&1 || true; \
		echo ""; \
	done

test-alu: analyze
	$(GHDL) -e $(GHDL_FLAGS) alu_tb
	$(GHDL) -r $(GHDL_FLAGS) alu_tb --stop-time=1000ns --wave=alu_tb.ghw

test-regs: analyze
	$(GHDL) -e $(GHDL_FLAGS) register_file_tb
	$(GHDL) -r $(GHDL_FLAGS) register_file_tb --stop-time=500ns --wave=regs_tb.ghw

test-pc: analyze
	$(GHDL) -e $(GHDL_FLAGS) program_counter_tb
	$(GHDL) -r $(GHDL_FLAGS) program_counter_tb --stop-time=500ns --wave=pc_tb.ghw

test-mem: analyze
	$(GHDL) -e $(GHDL_FLAGS) data_memory_tb
	$(GHDL) -r $(GHDL_FLAGS) data_memory_tb --stop-time=1000ns --wave=mem_tb.ghw

test-ctrl: analyze
	$(GHDL) -e $(GHDL_FLAGS) controller_tb
	$(GHDL) -r $(GHDL_FLAGS) controller_tb --stop-time=2000ns --wave=ctrl_tb.ghw

test-sp: analyze
	$(GHDL) -e $(GHDL_FLAGS) stack_pointer_tb
	$(GHDL) -r $(GHDL_FLAGS) stack_pointer_tb --stop-time=500ns --wave=sp_tb.ghw

test-cpu: analyze
	$(GHDL) -e $(GHDL_FLAGS) cpu_top_tb
	$(GHDL) -r $(GHDL_FLAGS) cpu_top_tb --stop-time=5000ns --wave=cpu_tb.ghw

clean:
	rm -f *.o *.cf *.ghw work-*.cf
	rm -f $(TB_ENTITIES)
