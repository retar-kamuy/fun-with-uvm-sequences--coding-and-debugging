`ifndef DRIVER_SVH_
`define DRIVER_SVH_

class driver extends uvm_driver#(transaction);
    `uvm_component_utils(driver)

    transaction t;
    interrupt_transaction isr;
    bit done;
    int value;

    bit [31:0] mem[1920*1024];

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
        done = 0;
    endfunction

    task interrupt_service_routine(interrupt_transaction isr_h);
        `uvm_info(get_type_name(), "Setting ISR", UVM_MEDIUM)
        done = 0;
        isr_h.DONE = 0;
        wait(done == 1);
        isr_h.VALUE = value;
        isr_h.DONE = 1;
    endtask

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(t);
            `uvm_info(get_type_name(), $sformatf("Got %s", t.convert2string()), UVM_MEDIUM)

            if ($cast(isr, t)) begin
                fork
                    interrupt_service_routine(isr);
                join_none
            end
            else begin
                #(t.duration);

                if (t.addr >= 1920*1024)
                    `uvm_fatal(get_type_name(), "ADDRESS FAILED")

                if (t.rw == WRITE)
                    mem[t.addr] = t.data;
                else if (t.rw == READ)
                    t.data = mem[t.addr];

                if ((t.rw == WRITE) && ((t.addr%42) == 0)) begin
                    done = 1;
                    value = mem[t.addr];
                end
            end
            seq_item_port.item_done();
        end
    endtask
endclass

`endif  // DRIVER_SVH_
